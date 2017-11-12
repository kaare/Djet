import React from 'react';
import ReactDOM from 'react-dom';
import TreeView from 'react-treeview';
import Dropzone from 'react-dropzone';

class DirView extends React.Component {
  emptyDir()  {
    return {
      collapsed: true,
      updated: false,
      dirs: [],
      files: []
    }
  }

  handleClick(node, callback) {
    node.collapsed = !node.collapsed;
    this.setState({current: node.name});
    callback(this.props.node.path + '/' + node.name);
//    this.getDirData(node);
  }

  collapseAll() {
    this.setState({
      collapsedBookkeeping: this.state.collapsedBookkeeping.map(() => true),
    });
  }

  getDirData(node) {
    const self = this;
    $.get('/djet/files',
      {
        path: node.name
      },
      function(result) {
        result.collapsed = true;
        node.dirs = result.dirs.map((dirName) => {
          var dir = self.emptyDir();
          dir.name = dirName;
          return dir
        })
        node.files = result.files;
        node.updated = true;
        self.setState({node: node});
      },
      'json'
    )
  }

  constructor(props) {
    super(props);
    if (typeof props.node.dirs === "undefined") {
      var node  = this.emptyDir();
      node.name = props.node.path;
      this.state = {
          node: node
      };
    } else {
      this.state = {
          node: props.node
      };
    }
    if (!this.state.node.updated) this.getDirData(this.state.node);
  }

  render() {

//    const collapsedBookkeeping = this.state.collapsedBookkeeping;
  const { callback } = this.props;
  const { node } = this.state;
    return (
      <div>
        {node.dirs.map((leaf) => {
          // Let's make it so that the tree also toggles when we click the
          // label. Controlled components make this effortless.
          const label =
            <span className="node" onClick={this.handleClick.bind(this, leaf, callback)}>
              {leaf.name}
            </span>;
          return (
            <TreeView
              key={leaf.name}
              nodeLabel={label}
              collapsed={leaf.collapsed}
              onClick={this.handleClick.bind(this, leaf)}>
              <DirView node={{path: node.name + '/' + leaf.name}} callback={this.props.callback}/>
            </TreeView>
          );
        })}
        {node.files.map(entry => <div className="info" key={entry}>{entry}</div>) }
      </div>
    );
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
      <div>
        Current: { current }
        <button onClick={this.collapseAll}>Collapse all</button>
        <DirView node={{path: topDir}} callback={this.setCurrent.bind(this)}/>
        <Dropfiles callback={this.Current.bind(this)} />
      </div>
    );
  }
};

ReactDOM.render(<FileTree />, document.getElementById('file-tree'));
