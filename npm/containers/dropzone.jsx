var React = require('react');
var ReactDOM = require('react-dom');
var Dropzone = require('react-dropzone');

var Dropzone = React.createClass({
    onDrop: function (files) {
      console.log('Received files: ', files);
    },

    render: function () {
      return (
          <div>
            <Dropzone onDrop={this.onDrop}>
              <div>Try dropping some files here, or click to select files to upload.</div>
            </Dropzone>
          </div>
      );
    }
});

ReactDOM.render(<Dropzone />, document.getElementById('dropzone'));
