function draw() {
      var container = document.getElementById("mynetwork");
      var data = {
         nodes: nodeSet,
         edges: edgeSet
      }
      network = new vis.Network(container, data, options);
      allNodes = nodeSet.get({returnType:"Object", order:"id"});
      allEdges = edgeSet.get({returnType:"Object"});
	  network.on("click",neighborhoodHighlight);
     makeSearch();
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
      var connectedEdges = network.getConnectedEdges(selectedNode);
      for(var edgeId in allEdges) {
         allEdges[edgeId].color = 'rgba(200,200,200,0.5)';
      }
      for(i = 0; i < connectedEdges.length; i++) {
         allEdges[connectedEdges[i]].color = null;
      }
   } else if (highlightActive == true) { //reset     
      for(var nodeId in allNodes) {
         allNodes[nodeId].color = undefined; 
         if(allNodes[nodeId].hiddenLabel !== undefined) {
            allNodes[nodeId].label = allNodes[nodeId].hiddenLabel;
            allNodes[nodeId].hiddenLabel = undefined;
         }
      }
      for(var edgeId in allEdges) {
         allEdges[edgeId].color = null;
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
   updateArray = [];
   for(edgeId in allEdges) {
      if(allEdges.hasOwnProperty(edgeId)) {
         updateArray.push(allEdges[edgeId]);
      }
   }
   edgeSet.update(updateArray);
}

function matchSearch() {
   var input = document.getElementById("classSearch").value.toUpperCase();
   console.log(input);
   var matches = [];
   for(var nodeId in allNodes) {
      if((allNodes[nodeId].title).toUpperCase().indexOf(input) > -1) {
         matches.push(nodeId);
      }
   }
   if(matches.length == 1) {
      network.focus(matches[0], {scale:1.0}); 
      highlightNode(matches[0]);
      
   }
}

function highlightNode(nodeId) {
   neighborhoodHighlight({nodes:[nodeId]});
}

//bootstrap stuff
function makeSearch() {
   var biglist = document.getElementById("schoolSearch");
   var schools = []; 
   var schoolMenu = [];
   //separate the nodes into lists
   for(var nodeId in allNodes) {
      var node = allNodes[nodeId];
      var item = document.createElement("li");
      var a = document.createElement("a");
      var fcn = "javascript:network.focus(\"" + nodeId + "\", {scale:1.0}); highlightNode(\"" + nodeId + "\");"; 
      a.href = fcn;
      a.tabindex = "-1";
      a.appendChild(document.createTextNode(node.title));
      item.appendChild(a);
      if(schools.indexOf(node.group) == -1) {
         schools.push(node.group);
         var list = document.createElement("ul");
         
         list.setAttribute("class","dropdown-menu col-xs-12 scrollable-menu");
         list.appendChild(item);   
         schoolMenu.push(list);
      } else {
         var ind = schools.indexOf(node.group);
         var list = schoolMenu[ind];
         list.appendChild(item);
         schoolMenu[ind] = list;
      }

      //this works
      /* 
      var opt = allNodes[nodeId].id;
      var li = document.createElement("li");
      var text = document.createTextNode(allNodes[nodeId].title);
      var link = document.createElement("a");
      var fcn = "javascript:network.focus(\"" + nodeId + "\", {scale:1.0}); highlightNode(\"" + nodeId + "\");"; 
      link.href = fcn;
      link.appendChild(text);
      li.appendChild(link);
      list.appendChild(li);
      */
   }
   for(var ind = 0; ind < schoolMenu.length; ind++) {
      /*
      list = document.createElement("li");
      mydiv = document.createElement("div");
      mydiv.setAttribute("class", "col-xs-12 input-group dropdown input-group");
      var span = document.createElement("span");
      span.setAttribute("class", "input-group-btn");
      var button = document.createElement("button");
      button.setAttribute("class", "btn btn-primary btn-block dropdown-toggle");
      button.type = "input-button";
      button.setAttribute("data-toggle", "dropdown");
      button.appendChild(document.createTextNode(schools[ind]));
      var span2 = document.createElement("span");
      span2.setAttribute("class", "caret");
      button.appendChild(span2);
      span.append(button);
      span.append(schoolMenu[ind]);
      mydiv.appendChild(span);
      list.appendChild(mydiv);
      biglist.append(list);
      */
      list = document.createElement("li");
      var span = document.createElement("span");
      span.setAttribute("class", "caret");
      list.setAttribute("class","dropdown-submenu");
      a = document.createElement("a");
      a.href = "#";
      a.tabindex = "-1";
      a.appendChild(document.createTextNode(schools[ind]));
      console.log(schools[ind]);
      a.appendChild(span);
      list.appendChild(a);
      list.appendChild(schoolMenu[ind]);
      biglist.append(list);
      console.log(list);
   }
   console.log(biglist);
}
