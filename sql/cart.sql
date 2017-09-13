-- Djet basetypes and nodes for the Shoppingcart Feature

BEGIN;

SET search_path=djet, public;

-- Features

INSERT INTO feature (name,version, description) VALUES ('cart', 0.01, 'Shoppingcart features');

-- Basetypes

INSERT INTO basetype (feature_id,name,title,datacolumns,handler,template) VALUES (currval('feature_id_seq'), 'cart','Shopping Cart','[
]','Djet::Engine::Cart','<domain>/basetype/cart.tx');
INSERT INTO basetype (feature_id,name,title,datacolumns,handler,template) VALUES (currval('feature_id_seq'), 'checkout','Shopping Cart Checkout','[
	{"name":"steps","title":"Checkout steps","type":"Str"},
	{"name":"orders_node","title":"Orders","type":"Str"},
	{"name":"recipients","title":"Order Recipients","type":"Structured"},
	{"name":"order_template","title":"Order Template","type":"Str"},
	{"name":"mail_template","title":"Mail Template","type":"Str"}
]','Djet::Engine::Checkout','<domain>/basetype/checkout/receipt.tx');
INSERT INTO basetype (feature_id,name,title,datacolumns,handler,template) VALUES (currval('feature_id_seq'), 'checkout_cart','Checkout Cart','[
]','Djet::Shop::Checkout::Cart','<domain>/basetype/checkout/cart.tx');
INSERT INTO basetype (feature_id,name,title,datacolumns,handler,template) VALUES (currval('feature_id_seq'), 'checkout_address','Checkout Address','[
	{"name":"company","title":"Company","type":"Str"},
	{"name":"name","title":"Name","type":"Str", "required": "on"},
	{"name":"street","title":"Address","type":"Str", "required": "on"},
	{"name":"postalcode","title":"Postal Code","type":"Int", "required": "on"},
	{"name":"city","title":"City","type":"Str", "required": "on"},
	{"name":"email","title":"Email","type":"Email", "required": "on"},
	{"name":"phone","title":"Telephone","type":"Str"}
]','Djet::Shop::Checkout::Address','<domain>/basetype/checkout/address.tx');
INSERT INTO basetype (feature_id,name,title,datacolumns,handler,template) VALUES (currval('feature_id_seq'), 'checkout_delivery','Checkout Delivery','[
]','Djet::Shop::Checkout::Delivery','<domain>/basetype/checkout/delivery.tx');
INSERT INTO basetype (feature_id,name,title,datacolumns,handler,template) VALUES (currval('feature_id_seq'), 'checkout_payment','Checkout Payment','[
]','Djet::Shop::Checkout::Payment','<domain>/basetype/checkout/payment.tx');
INSERT INTO basetype (feature_id,name,title,datacolumns,handler,template) VALUES (currval('feature_id_seq'), 'checkout_receipt','Checkout Receipt','[
]','Djet::Shop::Checkout::Receipt','<domain>/basetype/checkout/receipt.tx');

-- Data Nodes

-- INSERT INTO data_node (basetype_id,parent_id,part,name,title,datacolumns) SELECT id,1,'cart','cart','Shopping Cart','{}' FROM basetype WHERE name='cart';

-- carts table

CREATE TABLE carts (
   code serial NOT NULL PRIMARY KEY,
   name text DEFAULT '' NOT NULL,
   uid text DEFAULT '' NOT NULL,
   session_id text DEFAULT '' NOT NULL,
   created integer DEFAULT 0 NOT NULL,
   last_modified integer DEFAULT 0 NOT NULL,
   order_id int REFERENCES djet.node(id),
   approved boolean,
   status text DEFAULT '' NOT NULL
);

-- cart_products

CREATE TABLE cart_products (
  cart integer NOT NULL REFERENCES carts
	ON DELETE CASCADE
	ON UPDATE CASCADE,
  sku int NOT NULL REFERENCES djet.node(id),
  name text NOT NULL DEFAULT '',
  price decimal(10,2) NOT NULL DEFAULT 0,
  "position" integer NOT NULL,
  quantity integer DEFAULT 1 NOT NULL,
  weight integer,
  priority integer DEFAULT 0 NOT NULL,
  PRIMARY KEY (cart, sku)
);

COMMIT;
