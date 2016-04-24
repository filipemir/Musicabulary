// var grabWordiness = function(artistID) {

//   request = $.ajax({
//     url: '/artists/' + artistID,
//     method: 'GET',
//     datatype: 'json',
//     data: { artist_id: artistID },
//     success: function(response) {
//       console.log(response)
//       if (response.status === '200') {
//         return response.wordiness;
//       } else {
//         return false;
//       }
//     },
//     error: function(response) {
//       return false;
//     }
//   });

// };

// var test = function() {
//   var grab = grabWordiness(10);
//   debugger;
// }

// test();