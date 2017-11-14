import React from 'react';
import ReactDOM from 'react-dom';
import TreeView from 'react-treeview';
import Dropzone from 'react-dropzone';

class NodeView extends React.Component {
  emptyDir()  {
    return {
      collapsed: true,
      updated: false,
      nodes: [],
    }
  }

  handleClick(node, callback) {
    node.collapsed = !node.collapsed;
    this.setState({current: node.name});
//    callback(this.props.node.path + '/' + node.name);
console.log('click', node);
    if (typeof node.nodes === "undefined") {
      this.getNodeData(node);
    }
  }

  collapseAll() {
    this.setState({
      collapsedBookkeeping: this.state.collapsedBookkeeping.map(() => true),
    });
  }

  getNodeData(node) {
    const self = this;
console.log('get', node);
    $.get('/djet',
      {
        path: node.path,
        template: 'treeview'
      },
      function(result) {
console.log('result', result);
        result.collapsed = true;
        node.nodes = result.nodes;
        node.title = result.title;
        node.path = result.path;
        node.updated = true;
        self.setState({node: node});
      },
      'json'
    )
  }

  constructor(props) {
    super(props);
    if (props.node.path === "/") {
      var node  = this.emptyDir();

      node.path = props.node.path;
      this.state = {
          node: node,
          callback: props.callback
      };
    if (!this.state.node.updated) this.getNodeData(this.state.node);
    } else {
      this.state = {
          node: props.node
      };
    }
  }

  render() {

  const { node, callback } = this.state;
//console.log(this.state);
    const label =
      <span className="node" onClick={this.handleClick.bind(this, node, callback)}>
        {node.title}
      </span>;
    return (
      <TreeView
        key={node.path}
        nodeLabel={label}
        defaultCollapsed={true}
        onClick={this.handleClick.bind(this, node)}
      >
        {node.nodes.map((leaf) => {
//console.log('leaf', leaf);
          var res;
          if (leaf.folder === 1) {
          // Let's make it so that the tree also toggles when we click the
          // label. Controlled components make this effortless.
          const label =
            <span className="node" onClick={this.handleClick.bind(this, leaf, callback)}>
              {leaf.title}
            </span>;
          res =
            <TreeView
              key={leaf.path}
              nodeLabel={label}
              defaultCollapsed={true}
              onClick={this.handleClick.bind(this, leaf)}>
              <NodeView node={{path: leaf.path}} callback={this.props.callback}/>
            </TreeView>
          } else {
            res = <div className="info" key={leaf.path}>{leaf.title}</div>
          }
          return res;
        })}
      </TreeView>
    );
  }
};

export class NodeTree extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
        current: '/',
    };
  }

  setCurrent(path) {
    this.setState({current: path});
  }

  Current(path) {
    return this.state.current;
  }

  render() {
    const topDir = '/';
    const current = this.state.current;
    return (
      <div>
        Current: { current }
        <button onClick={this.collapseAll}>Collapse all</button>
        <NodeView node={{path: topDir}} callback={this.setCurrent.bind(this)}/>
      </div>
    );
  }
};

ReactDOM.render(<NodeTree />, document.getElementById('node-tree'));
