import cx from 'classnames';
import React, { Component } from 'react';
import ReactDOM from 'react-dom';
import Tree from 'react-ui-tree';
import Dropzone from 'react-dropzone';

class DirView extends Component {
  emptyDir(title, path)  {
    return {
      title: title,
      path: path,
      collapsed: true,
      children: [],
    }
  }

  state = {
    active: null,
    tree: this.emptyDir('root', '/')
  };

  constructor(props) {
    super(props);
    this.state.globalState = props.callback;
    this.getDirData(this.state.tree);
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
    if (!node.collapsed) this.getDirData(node);
  };

  onClickNode = node => {
    if (typeof(node.path) !== "undefined") this.state.globalState(node.path);
    this.setState({
      active: node
    });
  };

  render() {
    const node = this.state.active;
    return (
          <Tree
            paddingLeft={20}
            tree={this.state.tree}
            onChange={this.handleChange}
            isNodeCollapsed={this.isNodeCollapsed}
            changeNodeCollapsed={this.renderCollapse}
            renderNode={this.renderNode}
          />
    );
  }

  handleChange = tree => {
    this.setState({
      tree: tree
    });
  };

  getDirData(node) {
    const self = this;
    $.get('/djet/files',
      {
        path: node.path
      },
      function(result) {
        result.collapsed = true;
        node.children = result.dirs.map((dirName) => {
          var dir = self.emptyDir(dirName, node.path + dirName + '/');
          return dir
        })
        for (var file in result.files) {
          node.children.push({title: result.files[file], leaf: true});
        }
        node.updated = true;
        self.setState({tree: self.state.tree});
      },
      'json'
    )
  }
};

class Dropfiles extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      callback: props.callback,
      files: []
    };
  }

  uploadFiles(dir) {
    var fd = new FormData();
    fd.append('path', dir);
    this.state.files.map((value, idx) => {
        fd.append(idx, value);
    });

    $.ajax({
        url: '/djet/files',
        type: 'POST',
        xhr: function() {
          var myXhr = $.ajaxSettings.xhr();
          return myXhr;
        },
        success: function (data) {
          console.log(data);
        },
        data: fd,
        dataType: 'json',
        cache: false,
        contentType: false,
        processData: false
    });
    return false;
  }

  onDrop(files) {
    // this.uploadFiles(files);
    var names = this.state.files.map(function(file) { return file.name; });
    var filtered = files.filter((file) => {
      return names.indexOf(file.name) === -1;
    });
    this.state.files.push(...filtered);
    this.setState({files: this.state.files});
  }

  render () {
    const dir = this.state.callback();
    return (
        <div>
          <Dropzone onDrop={this.onDrop.bind(this)}>
            <div>Try dropping some files here, or click to select files to upload.</div>
          </Dropzone>
          <div>
  	        Files to upload to {dir}:
            {this.state.files.map(entry => <div className="info" key={entry.name}>{entry.name}</div>) }
            <button onClick={this.uploadFiles.bind(this, dir)}>Upload</button>
          </div>
        </div>
    );
  }
};

export class FileTree extends React.Component {
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
      <div className="djet">
        <div className="tree">
          <DirView node={{path: topDir}} callback={this.setCurrent.bind(this)}/>
        </div>
        <div className="node-data">
          <Dropfiles callback={this.Current.bind(this)} />
        </div>
      </div>
    );
  }
};

ReactDOM.render(<FileTree />, document.getElementById('file-tree'));
