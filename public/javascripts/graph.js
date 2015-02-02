!function() {
  var width = 800,
      height = 750;

  var color = d3.scale.category20();

  var force = d3.layout.force()
      .charge(-1)
      .linkDistance(20)
      .size([width, height]);

  var svg = d3.select('svg')
      .attr('viewBox', '0 0 ' + width + ' ' + height)
      .attr('preserveAspectRatio', 'YMid meet');

  d3.json('/enron-email-graph/public/datasets/enron.json', function(error, graph) {
    force
        .nodes(graph.nodes)
        .links(graph.links)
        .start();

    var link = svg.selectAll('line')
        .data(graph.links)
      .enter().append('line')

    var node = svg.selectAll('circle')
        .data(graph.nodes)
      .enter().append('circle')
        .attr('r', 2)
        .call(force.drag);

    node.append('title')
        .text(function(d) { return d.name; });

    force.on('tick', function() {
      link.attr('x1', function(d) { return d.source.x; })
          .attr('y1', function(d) { return d.source.y; })
          .attr('x2', function(d) { return d.target.x; })
          .attr('y2', function(d) { return d.target.y; });

      node.attr('cx', function(d) { return d.x; })
          .attr('cy', function(d) { return d.y; });
    });
  });
}()
