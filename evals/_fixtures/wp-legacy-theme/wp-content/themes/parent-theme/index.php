<?php
/**
 * Gabarit principal du thème parent (fixture devflow).
 *
 * @package Parent_Theme
 */

get_header();

while ( have_posts() ) {
	the_post();
	the_title( '<h2>', '</h2>' );
	the_excerpt();
}

get_footer();
