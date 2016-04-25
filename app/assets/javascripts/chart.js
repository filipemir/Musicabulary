// Adapted from Amelia Bellamy-Royds' code here: http://fiddle.jshell.net/6cW9u/8/
var svg = d3.select("svg.bubble-chart");
var chart = d3.select("div.top-artists")
var bubbles = d3.selectAll("div.artist-bubble")

// Set spatial variables
var margins = 150;
var padding = 5;
var radius = 20;
var diameter = 2 * radius;
var popupWidth = 270;

var digitsRegex = /\d+/;
var prettyInteger = d3.format(",");

var width = window.getComputedStyle(svg[0][0])["width"];
var height = window.getComputedStyle(svg[0][0])["height"];
width = digitsRegex.exec(width)[0];
height = Math.min(digitsRegex.exec(height)[0], width);
var canvasWidth = width - 2 * margins;
var canvasHeight = height - 2 * margins;

var baselineHeight = (margins + height)/2;

// Initialize data array
dataset = []
var N = bubbles[0].length, i = N;
while(i--)dataset.push({ 
  startX: margins - radius + i * (canvasWidth / (N - 1)),
  startY: margins / 2
});

// xValues = dataset.map(function(o) { return o.x });
// var min = d3.min(xValues)
// var max = d3.max(xValues)
var min = 0;
var max = 1;

var xScale = d3.scale.linear()
  .domain([min, max])
  .range([margins - radius, width - margins - radius]);

svg.append("line")
  .attr("x1", xScale.range()[0] + radius)
  .attr("x2", xScale.range()[1] + radius )
  .attr("transform", "translate(0," + baselineHeight + ")");

// Quadtree to manage data conflicts
var quadtree = d3.geom.quadtree()
  .x(function(d) { return xScale(d.x); })
  .y(function(d) { return d.y; })
  .extent([[xScale(min),0],[xScale(max),0]]);

var quadroot = quadtree([]);

// Function to find potential overlapping circles
function findNeighbours(root, scaledX) {
  var neighbours = [];
  root.visit(function(node, x1, x2, y1, y2) {
    var p = node.point;
    if (p) {
      var overlap, neighborX = xScale(p.x);
      if (neighborX < scaledX) { //the point is to the left of x
        overlap = (neighborX + radius + padding >= scaledX - radius);
      } else { //the point is to the right
        overlap = (scaledX + radius + padding >= neighborX - radius);
      };
      if (overlap) neighbours.push(p);
    }
    return (x1 - radius > scaledX + radius + padding) &&
           (x2 + radius < scaledX - radius - padding);
  });
  return neighbours;
}

// Function to calculate offset when circles overlap
function calculateOffset() {
  return function(d) {
    neighbours = findNeighbours(quadroot, xScale(d.x));
    var n = neighbours.length;
    var upperEnd = 0, lowerEnd = 0;
    if (n) {
      var j = n, occupied = new Array(n);
      while (j--) {
        var p = neighbours[j];
        var hypotenuse = 2*radius + padding;
        var base = xScale(d.x) - xScale(p.x);
        var vertical = Math.sqrt(hypotenuse*hypotenuse - base*base);
        occupied[j] = [p.offset + vertical, p.offset - vertical];
      }
      occupied = occupied.sort(function(a,b) { return a[0] - b[0]; });
      j = n;
      lowerEnd = upperEnd = 1/0; //infinity
      while (j--) {
        if (lowerEnd > occupied[j][0]) {
          upperEnd = Math.min(lowerEnd, occupied[j][0]);
          lowerEnd = occupied[j][1];
        } else {
          lowerEnd = Math.min(lowerEnd, occupied[j][1]);
        }
      }
    }
    d.offset = (Math.abs(upperEnd) < Math.abs(lowerEnd)) ? upperEnd : lowerEnd;
    d.y = baselineHeight - radius + d.offset;
    return d.y + 'px';
  };
}

var setInitialPosition = function(d, i) {
  var bubble = d3.select(this);
  bubble.style("left", d.startX + 'px').style("top", d.startY + 'px');
};

var attachPopUp = function(d, i) {
  var bubble = d3.select(this);
  var artistID = digitsRegex.exec(bubble.attr("id"))[0];
  var popup = d3.select('#popup-' + artistID);
  bubble.on("mouseover", function() {
    var x = parseFloat(d3.select(this).style("left")) - popupWidth/2 + radius;
    var y = parseFloat(d3.select(this).style("top")) + diameter + padding + 10;
    popup.classed("hidden", false);
    popup.style("left", x + "px")
      .style("top", y + "px");
  })
  bubble.on("mouseout", function() {
    popup.classed("hidden", true);
  })
};

var setWordiness = function(d, i) {
  var bubble = d3.select(this);
  var artistID = digitsRegex.exec(bubble.attr("id"))[0];
  var popup = d3.select('#popup-' + artistID);

  request = $.ajax({
    url: '/artists/' + artistID,
    method: 'GET',
    datatype: 'json',
    success: function(response) {
      updateData(response.wordiness, bubble, d, i);
    }
  });
};

function updateData(xValue, bubble, d, i) {
  if (xValue !== null) {
    d.x = xValue;
    if (xValue > xScale.domain()[1]) {
      rescale(xValue);
    };
    placeBubble.call(bubble[0][0], d, i);
  };
};

function placeBubble(d, i) {
    bubble = d3.select(this);
    var xScaled = xScale(d.x) + 'px';
    bubble.transition().delay(110 * i).duration(100)
      .style("left", xScaled)
      .style("top", calculateOffset());
    bubble.classed("loading", false);
    quadroot.add(d);
    updatePopup(bubble, d.x);
};

function rescale(newValue) {
  var max = newValue;
  xScale.domain([min, max]);
  quadroot = quadtree([]);
  loaded = bubbles.filter(function(d, i) {
    return !d3.select(this).classed('loading');
  });
  loaded.each(placeBubble);
};

var updatePopup = function(bubble, wordiness) {
  var artistID = digitsRegex.exec(bubble.attr("id"))[0];
  var popup = d3.select("#popup-" + artistID);
  popup.select(".wordiness").classed("hidden", false);
  popup.select(".wordiness-number").text(prettyInteger(wordiness));
  popup.select(".placeholder").remove();
}

bubbles.data(dataset)
  .classed("hidden", false)
  .each(setInitialPosition)
  .each(attachPopUp)
  .each(setWordiness)
