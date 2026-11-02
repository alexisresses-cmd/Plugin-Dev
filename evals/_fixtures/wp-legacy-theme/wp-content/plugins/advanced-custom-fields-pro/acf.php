<?php
/**
 * Plugin Name: Advanced Custom Fields PRO
 * Plugin URI: https://www.advancedcustomfields.com
 * Description: Fichier factice de la fixture devflow (extension tierce, jamais modifiée).
 * Version: 6.2.7
 * Author: WP Engine
 * Text Domain: acf
 *
 * @package ACF
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

if ( ! function_exists( 'get_field' ) ) {
	/**
	 * Retourne la valeur d'un champ ACF (version factice : lit la méta brute).
	 *
	 * @param string    $selector Nom du champ.
	 * @param int|false $post_id  Identifiant du contenu.
	 * @return mixed
	 */
	function get_field( $selector, $post_id = false ) {
		$post_id = $post_id ? $post_id : get_the_ID();
		return get_post_meta( $post_id, $selector, true );
	}
}
