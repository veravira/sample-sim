--filename=/Users/vera.kalinichenko/Downloads/t/dataset.txt
--pig -x local -f simSmall.pig -param filename=/Users/vera.kalinichenko/Downloads/t/dataset.txt
REGISTER '../../../target/sample-sim-1.0-SNAPSHOT.jar';
define overlap com.similarity.OverlapUDF;

A = LOAD '$filename' USING PigStorage('\t') as (id:int, item:int);

agrpd = GROUP A BY item;

itemsJoined = JOIN A BY item, agrpd BY group;
-- will look only at items that participated in multiple ids; items that where choosen by multiple ids
split itemsJoined into itemsJoinedGrp if COUNT($3)>1, itemsOneId if COUNT($3)==1;

--store itemsJoinedGrp into 'feb5/items_joinedGrp';
--store itemsOneId into 'feb5/itemsOneId';

-- treat itemsOneId separately, the items similary of that dataset is either o or 1/sqrt(2)= 0.707
-- it's ZERO when items belong to two different ids only
-- it's 0.707 when two items where "picked" by the same ID
prep1 = foreach itemsOneId generate $0 as id, $1 as item;
prep2 = group prep1 by id;
prep3 = foreach prep2 generate group, $1.$1 as item, (COUNT($1) == 1?0:0.707);
common1 = filter prep3 by $2==0.707;
common2 = foreach common1 generate $1 as items, $2 as cos_sim;

itemInManyIds = foreach itemsJoinedGrp generate $1 as item, $3, COUNT($3) as totalNumberOfIds;
itemInManyIdsDist = distinct itemInManyIds;
itemInManyIdsDistOrd = order itemInManyIdsDist by $2 desc;
items= foreach itemInManyIdsDistOrd generate *;
crossItems = cross itemInManyIdsDistOrd, items;
crossItems1 = foreach crossItems generate $0 as itemL, $1 as tL, $2 as countL, $3 as itemR, $4 as tR, $5 as countR;
-- create an order such as itemL number less than itemR to remove duplicates
crossItems2L = filter crossItems1 by (itemL<itemR);
crossItems2R = filter crossItems1 by (itemL>itemR);
crossItems3L = distinct crossItems2L;
crossItems3R = distinct crossItems2R;
-- sets crossItems3L aqnd crossItems3R have the same information
-- will continue to work with crossItems3L
--store crossItems3L into 'feb5/crossItems3CosL';
--store crossItems3R into 'feb5/crossItems3CosR';
data = foreach crossItems3L generate $0 as item1, $3 as item2, $1.$0 as idsL, $2 as countL, $4.$0 as idsR, $5 as countR;
d = foreach data generate item1, item2, overlap(idsL, idsR) as top, SQRT(countL*countR) as bottom;
result = foreach d generate TOTUPLE(item1, item2), (double)(top/bottom);
result = foreach d generate item1, item2, top, bottom, (double)(top/bottom); 


