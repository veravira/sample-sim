REGISTER '../../../target/sample-sim-1.0-SNAPSHOT.jar';
REGISTER '../../../lib/datafu-1.2.0.jar';
--define FirstTupleFromBag datafu.pig.bags.FirstTupleFromBag();
define pairs datafu.pig.bags.UnorderedPairs();

A = load 'd1.txt' using PigStorage('\t') as (b:bag {t1:tuple(item:int)}, cos:double);
small = filter A by (SIZE($0)==1);
big = filter A by (SIZE($0)>1);
d1 = foreach big generate pairs(b) as tup, cos;
--store d1 into 'd1';
d2 = foreach d1 generate flatten($0), cos;
--store d2 into 'd2';
dump d2;	