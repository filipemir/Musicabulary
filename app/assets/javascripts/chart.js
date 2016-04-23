// Adapted from Amelia Bellamy-Royds' js-fiddle here: http://fiddle.jshell.net/6cW9u/8/

//create data array//
var dataset = [];
var N = 50, i = N;
var randNorm = d3.random.normal(0.5,0.2)
while(i--)dataset.push({
  x: randNorm()
});

var radius = 20;
var diameter = 2*radius;
var popupWidth = 270;
var svg = d3.select("svg");
var margin = 150;
var padding = 6;
var maxRadius = 25;

var digits_regex = /(\d*)/;
var width = window.getComputedStyle(svg[0][0])["width"];
width = digits_regex.exec(width)[0];
var height = window.getComputedStyle(svg[0][0])["height"];
height = Math.min(digits_regex.exec(height)[0], width);

var baselineHeight = (margin + height)/2;

xValues = dataset.map(function(o) {
    return o.x
  });
min = d3.min(xValues)
max = d3.max(xValues)

var xScale = d3.scale.linear()
        .domain([min,max])
        .range([margin,width-margin]);


var threads = svg.append("g")
    .attr("class", "threads");

var bubbleLine = svg.append("g")
        .attr("class", "bubbles")
        .attr("transform",
              "translate(0," + baselineHeight + ")");

    bubbleLine.append("line")
        .attr("x1", xScale.range()[0])
        .attr("x2", xScale.range()[1]);
//________________//

//Create Quadtree to manage data conflicts & define functions//
var quadtree = d3.geom.quadtree()
        .x(function(d) { return xScale(d.x); })
        .y(0) //constant, they are all on the same line
        .extent([[xScale(min),0],[xScale(max),0]]);
    //extent sets the domain for the tree
    //using the format [[minX,minY],[maxX, maxY]]
    //optional if you're adding all the data at once

var quadroot = quadtree([]);
          //create an empty adjacency tree;
          //the function returns the root node.

// Find the all nodes in the tree that overlap a given circle.
// quadroot is the root node of the tree, scaledX is the position
// of the circle on screen.
function findNeighbours(root, scaledX) {
  var neighbours = [];
  root.visit(function(node, x1, x2, y1, y2) {
    var p = node.point;
    if (p) {
      var overlap, scaledX2 = xScale(p.x);
      if (scaledX2 < scaledX) {
        //the point is to the left of x
        overlap = (scaledX2 + radius + padding >= scaledX - radius);
      } else {
        //the point is to the right
        overlap = (scaledX + radius + padding >= scaledX2 - radius);
      }
      if (overlap) neighbours.push(p);
    }
    return (x1 - radius > scaledX + radius + padding) &&
           (x2 + radius < scaledX - radius - padding);
  });
  return neighbours;
}

function calculateOffset() {
  return function(d) {
    neighbours = findNeighbours(quadroot, xScale(d.x));
    var n = neighbours.length;
    var upperEnd = 0, lowerEnd = 0;
    if (n) {
        //for every circle in the neighbour array
        // calculate how much farther above
        //or below this one has to be to not overlap;
        //keep track of the max values
        var j = n, occupied = new Array(n);
        while (j--) {
            var p = neighbours[j];
            var hypotenuse = 2*radius + padding;
            var base = xScale(d.x) - xScale(p.x);
            var vertical = Math.sqrt(hypotenuse*hypotenuse - base*base);
            occupied[j] = [p.offset + vertical, p.offset - vertical];
            //max and min of the zone occupied
            //by this circle at x=xScale(d.x)
        }
        occupied = occupied.sort(function(a,b) { return a[0] - b[0]; });
        //sort by the max value of the occupied block
        j = n;
        lowerEnd = upperEnd = 1/0;//infinity
        while (j--) {
          //working from the end of the "occupied" array,
          //i.e. the circle with highest positive blocking value:
          if (lowerEnd > occupied[j][0]) {
              upperEnd = Math.min(lowerEnd, occupied[j][0]);
              lowerEnd = occupied[j][1];
          } else {
              lowerEnd = Math.min(lowerEnd, occupied[j][1]);
          }
        }
      }
      //assign this circle the offset that is smaller
      //in magnitude:
      d.offset = (Math.abs(upperEnd)<Math.abs(lowerEnd)) ? upperEnd : lowerEnd;
      return baselineHeight  - radius + d.offset + 'px'
  };
}

// <div id="artist-test" style="position: absolute; left: 30px; top: 30px;">

//Create circles!//
var maxR = 0;

var chart = $('div.chart')

var chart = d3.select('div.chart')

d3.selection.prototype.moveToFront = function() {
  return this.each(function(){
    this.parentNode.appendChild(this);
  });
};

chart.selectAll("div")
          .data(dataset)
          .enter()
          .append("div")
          .attr("id", "artist-test")
          .style("position", "absolute")
          .each(function(d, i) {
            //for each circle, calculate it's position
            //then add it to the quadtree
            //so the following circles will avoid it.
            var scaledX = xScale(d.x) - radius + 'px';
            var scaledY = '0px'
            d3.select(this)
                .style("left", scaledX)
                .style("top", scaledY)
                .transition().delay(110*i).duration(100)
                .style("top", calculateOffset());
            quadroot.add(d);

            d3.select(this)
                .on("mouseover", function() {
        var xPosition = parseFloat(d3.select(this).style("left")) - popupWidth/2 + radius;
        var yPosition = parseFloat(d3.select(this).style("top")) + diameter + padding + 10;
                    var popup = d3.select('.popup');
                  popup.classed("hidden", false);
                    popup.style("left", xPosition + "px")
                         .style("top", yPosition + "px")
                         .moveToFront();
                })
                .on("mouseout", function() {
                  var popup = d3.select('.popup');
                  popup.classed("hidden", true);
                })
          });
