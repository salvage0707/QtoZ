import '../../css/articles/new.css';

$( "form" ).on( "submit", function( event ) {
  event.preventDefault();
  let data = JSON.stringify( $(this).serializeArray() ); 
  console.log( data );
});


