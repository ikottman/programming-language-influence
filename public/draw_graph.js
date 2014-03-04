var graph = Viva.Graph.graph();

var graphics = Viva.Graph.View.svgGraphics(),
    nodeSize = 80;
var layout = Viva.Graph.Layout.forceDirected(graph, {
    springLength : 5,
    springCoeff : 0.000004,
    dragCoeff : 0.01,
    gravity : -2.5
});
// In this example we fire off renderer before anything is added to
// the graph:
var renderer = Viva.Graph.View.renderer(graph, {
        graphics : graphics,
        layout : layout
    });
renderer.run();

graphics.node(function(node) {
    return Viva.Graph.svg('image')
         .attr('width', nodeSize)
         .attr('height', nodeSize)
         .link(node.data['logo']);
}).placeNode(function(nodeUI, pos) {
    nodeUI.attr('x', pos.x - nodeSize / 2).attr('y', pos.y - nodeSize / 2);
});


// To render an arrow we have to address two problems:
// 1. Links should start/stop at node's bounding box, not at the node center.
// 2. Render an arrow shape at the end of the link.

// Rendering arrow shape is achieved by using SVG markers, part of the SVG
// standard: http://www.w3.org/TR/SVG/painting.html#Markers
var createMarker = function(id) {
        return Viva.Graph.svg('marker')
                   .attr('id', id)
                   .attr('viewBox', "0 0 10 10")
                   .attr('refX', "10")
                   .attr('refY', "5")
                   .attr('markerUnits', "strokeWidth")
                   .attr('markerWidth', "20")
                   .attr('markerHeight', "15")
                   .attr('orient', "auto");
    },

    marker = createMarker('Triangle');
marker.append('path').attr('d', 'M 0 0 L 10 5 L 0 10 z');

// Marker should be defined only once in <defs> child element of root <svg> element:
var defs = graphics.getSvgRoot().append('defs');
defs.append(marker);

var geom = Viva.Graph.geom();

graphics.link(function(link){
    // Notice the Triangle marker-end attribe:
    return Viva.Graph.svg('path')
               .attr('stroke', 'gray')
               .attr('marker-end', 'url(#Triangle)');
}).placeLink(function(linkUI, fromPos, toPos) {
    // "Links should start/stop at node's bounding box, not at the node center."

    // For rectangular nodes Viva.Graph.geom() provides efficient way to find
    // an intersection point between segment and rectangle
    var toNodeSize = nodeSize,
        fromNodeSize = nodeSize;

    var from = geom.intersectRect(
            // rectangle:
                    fromPos.x - fromNodeSize / 2, // left
                    fromPos.y - fromNodeSize / 2, // top
                    fromPos.x + fromNodeSize / 2, // right
                    fromPos.y + fromNodeSize / 2, // bottom
            // segment:
                    fromPos.x, fromPos.y, toPos.x, toPos.y)
               || fromPos; // if no intersection found - return center of the node

    var to = geom.intersectRect(
            // rectangle:
                    toPos.x - toNodeSize / 2, // left
                    toPos.y - toNodeSize / 2, // top
                    toPos.x + toNodeSize / 2, // right
                    toPos.y + toNodeSize / 2, // bottom
            // segment:
                    toPos.x, toPos.y, fromPos.x, fromPos.y)
                || toPos; // if no intersection found - return center of the node

    var data = 'M' + from.x + ',' + from.y +
               'L' + to.x + ',' + to.y;

    linkUI.attr("d", data);
});

// get the data and add it to the graph
$.ajax("/influenced", {
    type:"GET",
    dataType:"json",
    success:function (res) {
    var arrayLength = res.length;
	for (var i = 0; i < arrayLength; i++) 
	{
		current_node = res[i][0]['data']['name'];
		graph.addNode(current_node, res[i][0]['data']);
	}
	for (var i = 0; i < arrayLength; i++) 
	{
		current_node = res[i][0]['data']['name'];
		influenced = res[i][0]['data']['influenced'].split("|");
		if (influenced != "NULL")
		{
			for (var j = 0; j < influenced.length; j++)
			{
				graph.addLink(current_node, influenced[j]);
			}
		}
	}



    }
})