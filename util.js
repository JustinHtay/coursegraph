var highlightActive = false;
function draw(nodes, edges, options) {
   var container = document.getElementById("mynetwork");
   var data = {
      nodes: nodes,
      edges: edges
   }
   var network = new vis.Network(container, data, options);
   var allNodes = nodes.get({returnType:"Object"});
   network.on("click", neighborhoodHighlight);
}

function neighborhoodHighlight(params) {
   if(params.nodes.length > 0) {
      highlightActive = true;
      var i,j;
      var selectedNode = params.nodes[0];
      var degrees = 2;
   

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

      //get connected nodes
      for(i = 1; i < degrees; i++) {
         for(j = 0; j < connectedNodes.length; j++) {
            allConnectedNodes = allConnectedNodes.concat(network.getConnectedNodes(connectedNodes[j]));
         }
      }
      //change color of second degree nodes
      for(i = 0; i < allConnectedNodes.length; i++) {
         allNodes[allConnectedNodes[i]].color = 'rgba(150,150,150,0.75)';
         if(allNodes[allConnectedNodes[i]].hiddenLabel !== undefined) {
            allNodes[allConnectedNodes[i]].label = allNodes[allConnectedNodes[i]].hiddenLabel;
            allNodes[allConnectedNodes[i]].hiddenLabel = undefined;
         }
      }
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
   nodes.update(updateArray);
}

