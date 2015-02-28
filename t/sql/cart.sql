BEGIN;

SET search_path=djet, public;

INSERT INTO data_node (basetype_id,parent_id,part,name,title,datacolumns) SELECT b.id,n.id,'cart','cart','Shopping Cart','{}' FROM basetype b, node n WHERE name='cart' AND n.part='';
INSERT INTO data_node (basetype_id,parent_id,part,name,title,datacolumns) SELECT b.id,n.id,'checkout','checkout','Indkøbskurv','{}' FROM basetype b, node n WHERE name='checkout' AND n.part='';
INSERT INTO data_node (basetype_id,parent_id,part,name,title,datacolumns) SELECT b.id,n.id,'cart','checkout_cart','Indkøbskurv','{}' FROM basetype b, node n WHERE name='checkout_cart' AND n.part='checkout';
INSERT INTO data_node (basetype_id,parent_id,part,name,title,datacolumns) SELECT b.id,n.id,'cart','checkout_address','Adresse','{}' FROM basetype b, node n WHERE name='checkout_address' AND n.part='checkout';
INSERT INTO data_node (basetype_id,parent_id,part,name,title,datacolumns) SELECT b.id,n.id,'cart','checkout_payment','Betaling','{}' FROM basetype b, node n WHERE name='checkout_payment' AND n.part='checkout';

COMMIT;
