// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$( document ).ready( function() {
  $( ".expand-project-details" ).click( function() {
    $( this ).hide();
    $( this ).parents( ".project" ).children( ".collapse-project-details" ).show();
    $( this ).parents( ".project" ).children( ".details" ).html( "<img src='/images/ajax-loader.gif' />" );
    $.get( "/projects/" + $( this ).attr( "data-project-id" ) );
    return false;
  } );
  $( ".collapse-project-details" ).click( function() {
    $( this ).hide();
    $( this ).parents( ".project" ).children( ".expand-project-details" ).show();
    $( this ).parents( ".project" ).children( ".details" ).html( "" );
    return false;
  } );
  $( ".submitter" ).live( "click", function() {
    $( this ).parents( "form" ).submit();
    return false;
  } );
  $( ".new-ticket" ).live( "click", function() {
    $( this ).hide();
    $( this ).parents( ".project" ).children( ".details" ).children( ".new-ticket-form" ).show();
    return false;
  } );
} );
