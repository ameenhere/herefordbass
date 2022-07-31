package here.ameen.hb.dao;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Repository;
@Repository
public class DefaultDataQualityDao
    implements
    DataQualityDao
{
    @Autowired
    private NamedParameterJdbcTemplate jdbcTemplate;
  
    @Value("${updateKillerName}")
    private String updateKillerNameQuery;
   
    @Value("${updateVictimName}")
    private String updateVictimNameQuery;
    
    @Value("${updatePlayerName}")
    private String updatePlayerNameQuery;
    
    @Override
    public List<String> fixIncorrectNames( List<String[]> names )
    {
        List<String> responses = new ArrayList<>();
        if ( names == null || names.size() == 0 )
        {
            return responses;
        }
        long count = 0;
        Map<String, String> paramMap = new HashMap<>();
        for ( int i = 0; i < names.size(); i++ )
        {
            if ( names.get( i ) == null || names.get( i ).length < 2 )
            {
                continue;
            }
            count = 0;
            paramMap.put( "actualName", names.get( i )[0] );
            for ( int j = 1; j < names.get( i ).length; j++ )
            {
                paramMap.put( "wrongName", names.get( i )[j] );
                count = count + jdbcTemplate.update( updateKillerNameQuery, paramMap );
                count = count + jdbcTemplate.update( updateVictimNameQuery, paramMap );
                
                for(int k= 1; k<=5; k++)
                {
                    String query = updatePlayerNameQuery.replaceAll( "playerColumn", "a" + k  );
                    count = count + jdbcTemplate.update( query, paramMap );
                }
                for(int k= 1; k<=5; k++)
                {
                    String query = updatePlayerNameQuery.replaceAll( "playerColumn", "h" + k  );
                    count = count + jdbcTemplate.update( query, paramMap );
                }
            }
            responses.add( names.get( i )[0] + "(" + count + ")" );
        }
        return responses;
    }

}
