<?php
/**
 * Fonctions d'affichage du thème enfant.
 *
 * @package Mon_Theme
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

function mt_get_event_date( $post_id = 0 ) {
	if ( ! function_exists( 'get_field' ) ) {
		return '';
	}
	$post_id = $post_id ? $post_id : get_the_ID();
	return get_field( 'event_date', $post_id );
}

function mt_format_event_date( $raw ) {
	if ( empty( $raw ) ) {
		return '';
	}
	$date = DateTime::createFromFormat( 'Ymd', $raw );
	if ( ! $date ) {
		return '';
	}
	return date_i18n( 'j F Y', $date->getTimestamp() );
}

function mt_event_meta() {
	$date  = mt_format_event_date( mt_get_event_date() );
	$place = function_exists( 'get_field' ) ? get_field( 'event_place' ) : '';
	echo '<p class="mt-event-meta">';
	if ( $date ) {
		echo '<span class="mt-event-meta__date">' . esc_html( $date ) . '</span>';
	}
	if ( $place ) {
		echo ' — <span class="mt-event-meta__place">' . esc_html( $place ) . '</span>';
	}
	echo '</p>';
}

function mt_posted_on() {
	echo '<time datetime="' . esc_attr( get_the_date( 'c' ) ) . '">' . esc_html( get_the_date() ) . '</time>';
}
