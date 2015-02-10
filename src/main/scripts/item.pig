REGISTER '../../../target/sample-sim-1.0-SNAPSHOT.jar';
REGISTER '../../../lib/datafu-1.2.0.jar';
DEFINE CountEach datafu.pig.bags.CountEach();
define SetIntersect datafu.pig.sets.SetIntersect();

--(32826,69195)
--6410	32826
--5677	32826

--6410	69195
--6410	69195

A = LOAD '$filename' USING PigStorage('\t') as (id:int, item:int);

ids = FOREACH (GROUP A BY id) GENERATE
  group as id,
  CountEach(A.(id)) as num_of_items_in_id;

items = FOREACH (GROUP A BY item) GENERATE
  group as item,
  CountEach(A.(item)) as num_of_ids,  A.(id) as ids;
a = foreach items generate $0, $1.$1, $2;


a1 = foreach a generate $0 as item, flatten($1) as in_ids, $2 as ids;
a2 = distinct a1;
--store a2 into 'items';
a3 = filter a2 by ($1>1 and $1<5);
--store a3 into 'items_small';

a4 = foreach a3 generate *;
--store a3 into 'items_small';
a5 = foreach a4 generate $0 as item, $1 as count, flatten($2);


a6 = foreach a5 generate *;
bb = join a5 by $2, a6 by $2;  
b1 = filter bb by ($0<$3);
--store b1  into 'b1';

b2 = foreach b1 generate $0 as item1, $3 as item2, $1 as c1, $4 as c2, SQRT($1*$4) as bot;
b3 = group b2 by ($0,$1);
b3D = distinct b3;

b4 = foreach b3D generate $0, COUNT($1) AS top, flatten($1.$4);
b = distinct b4;
result = foreach b generate $0, (double)(top-1)/bot;
store result into 'result'; 
