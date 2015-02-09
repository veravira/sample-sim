package com.similarity;

import java.io.IOException;
import java.util.Iterator;

import org.apache.pig.EvalFunc;
import org.apache.pig.data.DataBag;
import org.apache.pig.data.Tuple;

public class OverlapUDF extends EvalFunc<Integer> {
	
	
    @Override
    public Integer exec(Tuple input) throws IOException {
    	int overlapSize = 0;
    	 // tuple.
    	System.out.println("OverlapUDF: ********************************************");
        DataBag bag1 = (DataBag)input.get(0);
        DataBag bag2 = (DataBag)input.get(1);
        System.out.println("OverlapUDF: bag1 = " +bag1.toString());
        System.out.println("OverlapUDF: bag2 = " +bag2.toString());
        Iterator it = bag1.iterator();
        Iterator it2 = bag2.iterator();
        while(it2.hasNext()) {
        	Tuple current = (Tuple)it2.next();
	        while (it.hasNext()){
	            Tuple t = (Tuple)it.next();
	            // Don't count nulls or empty tuples
	            if (t != null && t.size() > 0 &&
	                t.get(0) != null && current.equals(t)) {
	              overlapSize++;
	            }
	        }
        }    	
        // expect one string	
        if (input == null) {
            System.out.println("OverlapUDF: requires one input parameter.");
            throw new IOException();                        
        }
        System.out.println("overlap  = " +overlapSize);
        System.out.println("OverlapUDF: ********************************************");
        return overlapSize;

    }   
}
