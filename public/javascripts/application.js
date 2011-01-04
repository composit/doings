// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$( document ).ready( function() {
  $( ".expand-project-details" ).live( "click", function() {
    $( this ).hide();
    $( this ).parents( ".project" ).children( ".collapse-project-details" ).show();
    $( this ).parents( ".project" ).children( ".details" ).html( "<img src='/images/ajax-loader.gif' />" );
    $.get( "/projects/" + $( this ).attr( "data-project-id" ) );
    return false;
  } );
  $( ".collapse-project-details" ).live( "click", function() {
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
  $( "#new-project" ).live( "click", function() {
    $( this ).hide();
    $( "#new-project-form" ).show();
    return false;
  } );
  $( "#new-goal" ).live( "click", function() {
    $( this ).hide();
    $( "#new-goal-form" ).show();
    return false;
  } );
  $( "#goal_workable_type" ).live( "change", function() {
    switch( $( this ).val() ) {
      case "Client":
        $.get( "/clients/workables" );
        break;
      case "Project":
        $.get( "/projects/workables" )
        break;
      case "Ticket":
        $.get( "/tickets/workables" );
        break;
      case "":
        $( "#workables" ).hide();
        break;
    }
  } );
  $( "#goal_period" ).live( "change", function() {
    if( $( this ).val() == "Daily" ) {
      $( "#weekday" ).show();
      $( "#goal_weekday" ).attr( "disabled", false );
    } else {
      $( "#weekday" ).hide();
      $( "#goal_weekday" ).attr( "disabled", true );
    }
  } );
  $( ".progressbar" ).each( function() {
    value = parseInt( $( this ).attr( "data-percent-complete" ) );
    $( this ).progressbar( { value: value } );
  } );
} );
