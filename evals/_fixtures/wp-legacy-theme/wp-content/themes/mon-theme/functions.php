<?php
/**
 * Fonctions du thème enfant Mon Thème.
 *
 * Historique : agenda des événements (CPT event + ACF), newsletter des membres, personnalisations du parent.
 *
 * @package Mon_Theme
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

define( 'MT_VERSION', '1.8.0' );
define( 'MT_DB_VERSION', '3' );
define( 'MT_NEWSLETTER_FROM', 'agenda@association.example' );

require_once get_stylesheet_directory() . '/inc/template-tags.php';

/*
 * ---------------------------------------------------------------------------
 * Mise en place
 * ---------------------------------------------------------------------------
 */

function mt_setup() {
	load_child_theme_textdomain( 'mon-theme', get_stylesheet_directory() . '/languages' );
	add_image_size( 'mt-event-thumb', 480, 320, true );
	add_image_size( 'mt-event-wide', 1200, 500, true );
	register_nav_menus(
		array(
			'mt-members' => __( 'Menu espace membres', 'mon-theme' ),
		)
	);
}
add_action( 'after_setup_theme', 'mt_setup', 20 );

function mt_enqueue_assets() {
	wp_enqueue_style( 'parent-theme-style', get_template_directory_uri() . '/style.css', array(), '4.2.1' );
	wp_enqueue_style( 'mt-style', get_stylesheet_uri(), array( 'parent-theme-style' ), MT_VERSION );
	wp_enqueue_script( 'mt-main', get_stylesheet_directory_uri() . '/js/main.js', array( 'jquery' ), MT_VERSION, true );
	wp_localize_script(
		'mt-main',
		'mtAjax',
		array(
			'url'   => admin_url( 'admin-ajax.php' ),
			'nonce' => wp_create_nonce( 'mt_subscribe' ),
		)
	);
}
add_action( 'wp_enqueue_scripts', 'mt_enqueue_assets' );

function mt_widgets_init() {
	register_sidebar(
		array(
			'name'          => __( 'Barre agenda', 'mon-theme' ),
			'id'            => 'mt-agenda',
			'before_widget' => '<section id="%1$s" class="widget %2$s">',
			'after_widget'  => '</section>',
			'before_title'  => '<h3 class="widget-title">',
			'after_title'   => '</h3>',
		)
	);
}
add_action( 'widgets_init', 'mt_widgets_init' );

/*
 * ---------------------------------------------------------------------------
 * Événements : CPT event, taxonomie event_type
 * ---------------------------------------------------------------------------
 */

function mt_register_event_cpt() {
	$labels = array(
		'name'          => __( 'Événements', 'mon-theme' ),
		'singular_name' => __( 'Événement', 'mon-theme' ),
		'add_new_item'  => __( 'Ajouter un événement', 'mon-theme' ),
		'edit_item'     => __( 'Modifier l\'événement', 'mon-theme' ),
		'all_items'     => __( 'Tous les événements', 'mon-theme' ),
	);
	register_post_type(
		'event',
		array(
			'labels'       => $labels,
			'public'       => true,
			'has_archive'  => true,
			'rewrite'      => array( 'slug' => 'agenda' ),
			'menu_icon'    => 'dashicons-calendar-alt',
			'supports'     => array( 'title', 'editor', 'thumbnail', 'excerpt' ),
			'show_in_rest' => true,
		)
	);
	register_taxonomy(
		'event_type',
		'event',
		array(
			'label'             => __( 'Types d\'événement', 'mon-theme' ),
			'hierarchical'      => true,
			'show_admin_column' => true,
			'show_in_rest'      => true,
			'rewrite'           => array( 'slug' => 'type-evenement' ),
		)
	);
}
add_action( 'init', 'mt_register_event_cpt' );

function mt_event_columns( $columns ) {
	$columns['mt_event_date'] = __( 'Date', 'mon-theme' );
	return $columns;
}
add_filter( 'manage_event_posts_columns', 'mt_event_columns' );

function mt_event_column_content( $column, $post_id ) {
	if ( 'mt_event_date' === $column ) {
		echo mt_format_event_date( mt_get_event_date( $post_id ) );
	}
}
add_action( 'manage_event_posts_custom_column', 'mt_event_column_content', 10, 2 );

function mt_event_archive_order( $query ) {
	if ( is_admin() || ! $query->is_main_query() ) {
		return;
	}
	if ( $query->is_post_type_archive( 'event' ) ) {
		$query->set( 'meta_key', 'event_date' );
		$query->set( 'orderby', 'meta_value' );
		$query->set( 'order', 'ASC' );
	}
}
add_action( 'pre_get_posts', 'mt_event_archive_order' );

/*
 * ---------------------------------------------------------------------------
 * Personnalisations du thème parent
 * ---------------------------------------------------------------------------
 */

function mt_excerpt_length( $length ) {
	return is_post_type_archive( 'event' ) ? 30 : $length;
}
add_filter( 'excerpt_length', 'mt_excerpt_length', 20 );

function mt_body_classes( $classes ) {
	if ( is_singular( 'event' ) ) {
		$classes[] = 'mt-single-event';
	}
	if ( is_user_logged_in() ) {
		$classes[] = 'mt-member';
	}
	return $classes;
}
add_filter( 'body_class', 'mt_body_classes' );

function mt_login_logo() {
	echo '<style>.login h1 a { background-image: url(' . get_stylesheet_directory_uri() . '/img/logo.png); }</style>';
}
add_action( 'login_enqueue_scripts', 'mt_login_logo' );

/*
 * ---------------------------------------------------------------------------
 * Shortcodes
 * ---------------------------------------------------------------------------
 */

function mt_contact_phone_shortcode( $atts ) {
	$atts = shortcode_atts( array( 'label' => __( 'Téléphone', 'mon-theme' ) ), $atts, 'mt_contact_phone' );
	$phone = get_option( 'mt_contact_phone', '' );
	if ( '' === $phone ) {
		return '';
	}
	return '<span class="mt-phone">' . esc_html( $atts['label'] ) . ' : ' . esc_html( $phone ) . '</span>';
}
add_shortcode( 'mt_contact_phone', 'mt_contact_phone_shortcode' );

/*
 * ---------------------------------------------------------------------------
 * Newsletter des membres : table, inscription AJAX
 * ---------------------------------------------------------------------------
 */

function mt_install_subscribers_table() {
	global $wpdb;
	if ( get_option( 'mt_db_version' ) === MT_DB_VERSION ) {
		return;
	}
	$table   = $wpdb->prefix . 'mt_subscribers';
	$charset = $wpdb->get_charset_collate();
	$sql     = "CREATE TABLE $table (
		id bigint(20) unsigned NOT NULL AUTO_INCREMENT,
		user_id bigint(20) unsigned NOT NULL DEFAULT 0,
		email varchar(190) NOT NULL,
		event_type varchar(50) NOT NULL DEFAULT '',
		created_at datetime NOT NULL,
		PRIMARY KEY  (id),
		KEY email (email)
	) $charset;";
	require_once ABSPATH . 'wp-admin/includes/upgrade.php';
	dbDelta( $sql );
	update_option( 'mt_db_version', MT_DB_VERSION );
}
add_action( 'after_switch_theme', 'mt_install_subscribers_table' );

/**
 * Inscription d'un membre connecté aux alertes « nouveaux événements ».
 * Appelée par js/main.js (action mt_subscribe), réponse JSON.
 */
function mt_ajax_subscribe() {
	global $wpdb;

	check_ajax_referer( 'mt_subscribe', 'nonce' );

	if ( ! current_user_can( 'read' ) ) {
		wp_send_json_error( array( 'message' => __( 'Vous devez être connecté.', 'mon-theme' ) ), 403 );
	}

	$user  = wp_get_current_user();
	$email = '';
	if ( isset( $_POST['email'] ) ) {
		$email = sanitize_email( wp_unslash( $_POST['email'] ) );
	}
	if ( '' === $email ) {
		$email = $user->user_email;
	}

	if ( ! is_email( $email ) ) {
		wp_send_json_error( array( 'message' => __( 'Adresse e-mail invalide.', 'mon-theme' ) ), 400 );
	}

	$domain  = strtolower( substr( strrchr( $email, '@' ), 1 ) );
	$blocked = array( 'yopmail.com', 'mailinator.com', 'jetable.org' );
	if ( in_array( $domain, $blocked, true ) ) {
		wp_send_json_error( array( 'message' => __( 'Les adresses jetables ne sont pas acceptées.', 'mon-theme' ) ), 400 );
	}

	$event_type = '';
	if ( ! empty( $_POST['event_type'] ) ) {
		$event_type = sanitize_key( wp_unslash( $_POST['event_type'] ) );
		if ( ! term_exists( $event_type, 'event_type' ) ) {
			$event_type = '';
		}
	}

	$table = $wpdb->prefix . 'mt_subscribers';

	$already = $wpdb->get_var( "SELECT COUNT(*) FROM $table WHERE email = '" . $email . "' AND event_type = '" . $event_type . "'" );
	if ( $already > 0 ) {
		wp_send_json_success(
			array(
				'message' => __( 'Vous êtes déjà inscrit.', 'mon-theme' ),
				'status'  => 'exists',
			)
		);
	}

	$now    = current_time( 'mysql' );
	$result = $wpdb->query(
		"INSERT INTO $table (user_id, email, event_type, created_at) VALUES (" . $user->ID . ", '" . $email . "', '" . $event_type . "', '" . $now . "')"
	);

	if ( false === $result ) {
		error_log( 'mt_ajax_subscribe : échec insertion ' . $wpdb->last_error );
		wp_send_json_error( array( 'message' => __( 'Erreur technique, réessayez plus tard.', 'mon-theme' ) ), 500 );
	}

	$subscriber_id = (int) $wpdb->insert_id;
	update_user_meta( $user->ID, 'mt_newsletter', 1 );

	$type_label = __( 'tous les événements', 'mon-theme' );
	if ( '' !== $event_type ) {
		$term = get_term_by( 'slug', $event_type, 'event_type' );
		if ( $term ) {
			$type_label = $term->name;
		}
	}

	$subject = sprintf( __( '[%s] Inscription aux alertes', 'mon-theme' ), get_bloginfo( 'name' ) );
	$body    = sprintf(
		__( "Bonjour %1\$s,\n\nVous recevrez désormais un e-mail pour chaque nouvel événement (%2\$s).\n\nPour vous désinscrire : %3\$s", 'mon-theme' ),
		$user->display_name,
		$type_label,
		home_url( '/mon-compte/' )
	);
	$headers = array(
		'From: ' . get_bloginfo( 'name' ) . ' <' . MT_NEWSLETTER_FROM . '>',
		'Content-Type: text/plain; charset=UTF-8',
	);
	$sent = wp_mail( $email, $subject, $body, $headers );

	$admin_email = get_option( 'admin_email' );
	wp_mail(
		$admin_email,
		__( 'Nouvelle inscription aux alertes', 'mon-theme' ),
		sprintf( '%s (%s) — %s', $user->display_name, $email, $type_label )
	);

	if ( ! $sent ) {
		error_log( 'mt_ajax_subscribe : e-mail de confirmation non envoyé à ' . $email );
	}

	do_action( 'mt_after_subscribe', $subscriber_id, $email, $event_type );

	wp_send_json_success(
		array(
			'message' => __( 'Inscription enregistrée, un e-mail de confirmation vous a été envoyé.', 'mon-theme' ),
			'status'  => 'created',
			'id'      => $subscriber_id,
		)
	);
}
add_action( 'wp_ajax_mt_subscribe', 'mt_ajax_subscribe' );

function mt_subscribers_count() {
	global $wpdb;
	return (int) $wpdb->get_var( "SELECT COUNT(*) FROM {$wpdb->prefix}mt_subscribers" );
}

/*
 * ---------------------------------------------------------------------------
 * Administration
 * ---------------------------------------------------------------------------
 */

function mt_dashboard_widget() {
	wp_add_dashboard_widget( 'mt_subscribers', __( 'Alertes événements', 'mon-theme' ), 'mt_dashboard_widget_render' );
}
add_action( 'wp_dashboard_setup', 'mt_dashboard_widget' );

function mt_dashboard_widget_render() {
	echo '<p>' . sprintf( __( '%d membres inscrits aux alertes.', 'mon-theme' ), mt_subscribers_count() ) . '</p>';
}

function mt_register_settings() {
	register_setting( 'general', 'mt_contact_phone', array( 'sanitize_callback' => 'sanitize_text_field' ) );
	add_settings_field( 'mt_contact_phone', __( 'Téléphone de contact', 'mon-theme' ), 'mt_contact_phone_field', 'general' );
}
add_action( 'admin_init', 'mt_register_settings' );

function mt_contact_phone_field() {
	echo '<input type="text" name="mt_contact_phone" value="' . esc_attr( get_option( 'mt_contact_phone', '' ) ) . '" class="regular-text">';
}
