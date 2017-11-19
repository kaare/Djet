
// import '../lib/react-ui-tree.less';
// import './theme.less';
// import './app.less';
import cx from 'classnames';
import React, { Component } from 'react';
import ReactDOM from 'react-dom';
import Tree from 'react-ui-tree';

class NodeTree extends Component {
  state = {
    active: null,
    tree: { title: 'root', path: '/' }
  };

  constructor(props) {
    super(props);
    //this.state = { count: 0 };
    this.getNodeData(this.state.tree);
  }

  renderNode = node => {
    return (
      <span
        className={cx('node', {
          'is-active': node === this.state.active
        })}
        onClick={this.onClickNode.bind(null, node)}
      >
        {node.title}
      </span>
    );
  };

  renderCollapse = node => {
    if (!node.collapsed) this.getNodeData(node);
  };

  onClickNode = node => {
    if (typeof node.children != "undefined") {
      this.getNodeData(node);
    }
  };

  render() {
    return (
      <div className="app">
        <div className="tree">
          <Tree
            paddingLeft={20}
            tree={this.state.tree}
            onChange={this.handleChange}
            isNodeCollapsed={this.isNodeCollapsed}
            changeNodeCollapsed={this.renderCollapse}
            renderNode={this.renderNode}
          />
        </div>
        <div className="inspector">
          <h1>
            Test
          </h1>
          <button onClick={this.updateTree}>update tree</button>
          <pre>{JSON.stringify(this.state.tree, null, '  ')}</pre>
        </div>
      </div>
    );
  }

  handleChange = tree => {
    this.setState({
      tree: tree
    });
  };

  updateTree = () => {
    const { tree } = this.state;
    this.setState({
      tree: tree
    });
  };

  getNodeData = node => {
    const self = this;
    $.get('/djet',
      {
        path: node.path,
        template: 'treeview'
      },
      function(result) {
        result.collapsed = true;
        node.children = result.children;
        result.children.map((child) => {
          child.collapsed = true;
        });
        node.title = result.title;
        node.path = result.path;
        self.setState({tree: self.state.tree});
      },
      'json'
    )
  }

}

ReactDOM.render(<NodeTree />, document.getElementById('node-tree'));
