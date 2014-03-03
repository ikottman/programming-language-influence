var graph = Viva.Graph.graph();

$.ajax("/influenced", {
    type:"GET",
    dataType:"json",
    success:function (res) {
    var arrayLength = res.length;
	for (var i = 0; i < arrayLength; i++) {
		//Do something
		influenced = res[i][0]['data']['influenced'].split("|");
		for (var j = 0; j < influenced.length; j++)
		{
			graph.addLink(res[i][0]['data']['name'], influenced[j]);
		}
	}
    }
})
var renderer = Viva.Graph.View.renderer(graph);
renderer.run();    

