function draw() {
      var container = document.getElementById("mynetwork");
      var data = {
         nodes: nodeSet,
         edges: edgeSet
      }
      network = new vis.Network(container, data, options);
      allNodes = nodeSet.get({returnType:"Object"});
	  network.on("click",neighborhoodHighlight);
	}
	function neighborhoodHighlight(params) {
   if(params.nodes.length > 0) {
      highlightActive = true;
      var i,j;
      var selectedNode = params.nodes[0];
      var degrees = 1;
   

      //mark nodes as hard to read
      for(var nodeId in allNodes) {
         allNodes[nodeId].color = 'rgba(200,200,200,0.5)';
         if(allNodes[nodeId].hiddenLabel == undefined) {
            allNodes[nodeId].hiddenLabel = allNodes[nodeId].label;
            allNodes[nodeId].label = undefined;
         }
      }
      var connectedNodes = network.getConnectedNodes(selectedNode);
      var allConnectedNodes = [];

      //first degree nodes
      for(i = 0; i < connectedNodes.length; i++) {
         allNodes[connectedNodes[i]].color = undefined;
         if(allNodes[connectedNodes[i]].hiddenLabel !== undefined) {
            allNodes[connectedNodes[i]].label = allNodes[connectedNodes[i]].hiddenLabel;
            allNodes[connectedNodes[i]].hiddenLabel = undefined;
         }
      }
      //reset main node
      allNodes[selectedNode].color = undefined;
      if(allNodes[selectedNode].hiddenLabel !== undefined) {
         allNodes[selectedNode].label = allNodes[selectedNode].hiddenLabel;
         allNodes[selectedNode].hiddenLabel = undefined;
      }
   } else if (highlightActive == true) {
      
      for(var nodeId in allNodes) {
         allNodes[nodeId].color = undefined; 
         if(allNodes[nodeId].hiddenLabel !== undefined) {
            allNodes[nodeId].label = allNodes[nodeId].hiddenLabel;
            allNodes[nodeId].hiddenLabel = undefined;
         }
      }
      highlightActive = false;
   }
   //convert into array
   var updateArray = [];
   for(nodeId in allNodes) {
      if(allNodes.hasOwnProperty(nodeId)) {
         updateArray.push(allNodes[nodeId]);
      }
   }
   nodeSet.update(updateArray);
}