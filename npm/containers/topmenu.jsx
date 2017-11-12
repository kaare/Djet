
var React = require('react');
var ReactDOM = require('react-dom');

var Menu = require('rc-menu');
Menu.injectCSS();

var TopMenu = React.createClass({
    render: function () {
    console.log(document.getElementById('topmenu').dataset);
    console.log(this.refs);
      return (
        <Menu>
            <MenuItem>1</MenuItem>
            <SubMenu title="2">
                <MenuItem>2-1</MenuItem>
            </SubMenu>
        </Menu>
      );
    }
});

ReactDOM.render(<TopMenu />, document.getElementById('topmenu'));
