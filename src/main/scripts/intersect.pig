/**
REGISTER '../../../lib/datafu-1.2.0.jar';
DEFINE CountEach datafu.pig.bags.CountEach();
define SetIntersect datafu.pig.sets.SetIntersect();

-- ({(3),(4),(1),(2),(7),(5),(6)},{(0),(5),(10),(1),(4)})
input = LOAD 'corr' AS (item1:int, B1:bag{T:tuple(val:int)}, item2:int, B2:bag{T:tuple(val:int)});

intersected = FOREACH input {
  sorted_b1 = ORDER B1 by val;
  sorted_b2 = ORDER B2 by val;
  GENERATE item1, item2, SetIntersect(sorted_b1,sorted_b2);
}

items = FOREACH (GROUP A BY item) GENERATE
  group as item,
  CountEach(A.(item)) as num_of_ids;


items = FOREACH intersected GENERATE
  item1, item2, SIZE($2);

  **/

REGISTER '../../../target/sample-sim-1.0-SNAPSHOT.jar';
REGISTER '../../../lib/datafu-1.2.0.jar';
define overlap com.similarity.OverlapUDF;
DEFINE CountEach datafu.pig.bags.CountEach();


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

b2 = foreach b1 generate $0 as item1, $3 as item2, $1 as c1, $4 as c2, SQRT($1*$4) as bot;
b3 = group b2 by ($0,$1);

b4 = foreach b3 generate $0, COUNT($1) AS top, flatten($1.$4);
b = distinct b4;
b5 = foreach b generate $0, (double)top/bot;
store b5 into 'b5'; 
