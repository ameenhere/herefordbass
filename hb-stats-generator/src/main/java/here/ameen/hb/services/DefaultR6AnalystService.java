package here.ameen.hb.services;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.Iterator;

import com.opencsv.CSVReader;

public class DefaultR6AnalystService implements R6AnalystService
{
    public void extractMatchDataFromFile( FileInputStream inputStream )
    {
    	  try (CSVReader reader = new CSVReader(new BufferedReader(new InputStreamReader(inputStream, "UTF-8")))
    			        ) {

    		     Iterator<String[]> iterable = reader.iterator();
    		    } catch (IOException e) {
    		      throw new RuntimeException("fail to parse CSV file: " + e.getMessage());
    		    }
    }
}
