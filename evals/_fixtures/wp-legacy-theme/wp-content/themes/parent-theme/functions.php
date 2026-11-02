<?php
/**
 * Fonctions du thème parent (thème commercial, fixture devflow).
 *
 * @package Parent_Theme
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

function parent_theme_setup() {
	load_theme_textdomain( 'parent-theme', get_template_directory() . '/languages' );
	add_theme_support( 'title-tag' );
	add_theme_support( 'post-thumbnails' );
	register_nav_menus(
		array(
			'primary' => __( 'Menu principal', 'parent-theme' ),
			'footer'  => __( 'Menu du pied de page', 'parent-theme' ),
		)
	);
}
add_action( 'after_setup_theme', 'parent_theme_setup' );

function parent_theme_scripts() {
	wp_enqueue_style( 'parent-theme-style', get_template_directory_uri() . '/style.css', array(), '4.2.1' );
}
add_action( 'wp_enqueue_scripts', 'parent_theme_scripts' );

function parent_theme_excerpt_more( $more ) {
	return ' <a class="more-link" href="' . esc_url( get_permalink() ) . '">' . esc_html__( 'Lire la suitte', 'parent-theme' ) . '</a>';
}
add_filter( 'excerpt_more', 'parent_theme_excerpt_more', 10 );
