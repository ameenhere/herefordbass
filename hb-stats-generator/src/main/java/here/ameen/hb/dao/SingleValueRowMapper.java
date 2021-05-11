package here.ameen.hb.dao;

import java.sql.ResultSet;
import java.sql.SQLException;

import org.springframework.jdbc.core.RowMapper;

import here.ameen.hb.model.SingleValue;

public class SingleValueRowMapper
    implements
    RowMapper<SingleValue>
{

    @Override
    public SingleValue mapRow( ResultSet rs, int rowNum )
        throws SQLException
    {
    	SingleValue sv = new SingleValue();
        sv.setPlayer( rs.getString( "player" ) );
        sv.setValue( rs.getLong( "value" ) );
        return sv;
    }

}
