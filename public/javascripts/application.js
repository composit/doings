// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$( document ).ready( function() {
  $( ".project-details" ).click( function() {
    $( this ).parents( ".details" ).html( "<img src='/images/ajax-loader.gif' />" );
    $.get( "/projects/" + $( this ).attr( "data-project-id" ) );
  } );
} );
