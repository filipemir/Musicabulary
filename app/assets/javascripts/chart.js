// Adapted from Amelia Bellamy-Royds' code here: http://fiddle.jshell.net/6cW9u/8/
var chart = d3.select("div.top-artists")
var svg = d3.select("svg.bubble-chart");
var bubbles = d3.selectAll("div.artist-bubble")

// Set spatial variables
var radius = 22;
var padding = 4;
var margins = 10 + radius;
var diameter = 2 * radius;
var popupWidth = 190;

var digitsRegex = /\d+/;
var prettyInt = d3.format(",");

var width = parseInt(d3.select(".bubble-chart").style("width")) - margins * 2;
var height = parseInt(d3.select(".bubble-chart").style("height")) - margins * 2;
var canvasWidth = width;
var canvasHeight = height;

var baselineHeight = 8 * diameter;

// Initialize data array
dataset = []
var N = bubbles[0].length, i = N;
while(i--)dataset.push({ 
  startX: margins - radius + i * (canvasWidth / (N - 1)),
  startY: 0
});

var min = 720;
var max = 780;

var xScale = d3.scale.linear()
  .domain([min, max])
  .range([margins, width]);

svg.append("line")
  .attr("x1", xScale.range()[0])
  .attr("x2", xScale.range()[1])
  .attr("transform", "translate(0," + baselineHeight + ")")
  .classed("baseline", true);

var dividerNum = 6;
for (var i = 1; i < dividerNum; i++) {
  var x = xScale.range()[1] * i / dividerNum
  svg.append("line")
    .attr("x1", x)
    .attr("x2", x)
    .attr("y1", baselineHeight - 250)
    .attr("y2", baselineHeight + 200)
    .classed("divider", true)

  var text = '1,000' + (i === 1 ? ' words' : '')
  svg.append("text")
    .classed("divider-num", true)
    .attr("x", x - 23)
    .attr("y", baselineHeight - 255)
    .text(text)
  };

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
        var hypotenuse = 2 * radius + padding;
        var base = xScale(d.x) - xScale(p.x);
        var vertical = Math.sqrt(hypotenuse * hypotenuse - base * base);
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
    var x = parseFloat(d3.select(this).style("left")) - popupWidth / 2 + radius;
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
      if (response.wordiness !== null) {
        updateData(response.wordiness, bubble, d, i)
      } else {
        updatePopup(bubble, false)
      };
    }
  });

};

function updateData(xValue, bubble, d, i) {
  if (xValue) {
    d.x = xValue;
    if (xValue < min || xValue > max) {
      rescale(xValue);
    };
    placeBubble.call(bubble[0][0], d, i);
  };
};

function rescale(newValue) {
  min = d3.min([min, newValue])
  max = d3.max([max, newValue]);
  xScale.domain([min, max]);
  quadroot = quadtree([]);
  loaded = bubbles.filter(function(d, i) {
    return !d3.select(this).classed('loading');
  });
  loaded.each(placeBubble);
};

function placeBubble(d, i) {
    bubble = d3.select(this);
    var xScaled = xScale(d.x) - radius + 'px';
    bubble.transition().delay(100 * i).duration(100)
      .style("left", xScaled)
      .style("top", calculateOffset());
    bubble.classed("loading", false);
    quadroot.add(d);
    updatePopup(bubble, d.x);
};

var updatePopup = function(bubble, wordiness, total_words) {
  var artistID = digitsRegex.exec(bubble.attr("id"))[0];
  var popup = d3.select("#popup-" + artistID);
    popup.select(".wordiness").classed("hidden", false);
  if (wordiness) { 
    popup.select(".wordiness-number").text(prettyInt(wordiness));
  } else {
    text = "Sorry but I couldn't find enough lyrics for this artist";
    popup.select(".wordiness").text(text);
  }
  popup.select(".placeholder").remove();
}

bubbles.data(dataset)
  .classed("hidden", false)
  .each(setInitialPosition)
  .each(attachPopUp)
  .each(setWordiness)


// function resize() {
//     var width = parseInt(d3.select("#graph").style("width")) - margin * 2;
//     var height = parseInt(d3.select("#graph").style("height")) - margin * 2;

//     /* Update the range of the scale with new width/height */
//     xScale.range([0, width]).nice(d3.time.year);
//     yScale.range([height, 0]).nice();

//      Update the axis with the new scale 
//     graph.select('.x.axis')
//       .attr("transform", "translate(0," + height + ")")
//       .call(xAxis);

//     graph.select('.y.axis')
//       .call(yAxis);

//     /* Force D3 to recalculate and update the line */
//     graph.selectAll('.line')
//       .attr("d", line);
//   }

//   d3.select(window).on('resize', resize); 

//   resize();
// });


