package here.ameen.hb.dao;

import java.sql.ResultSet;
import java.sql.SQLException;

import org.springframework.jdbc.core.RowMapper;

import here.ameen.hb.model.Nemesis;

public class NemesisRowMapper
    implements
    RowMapper<Nemesis>
{

    @Override
    public Nemesis mapRow( ResultSet rs, int rowNum )
        throws SQLException
    {
        Nemesis nemesis = new Nemesis();
        nemesis.setKillerName( rs.getString( "killer_name" ) );
        nemesis.setVictimName( rs.getString( "victim_name" ) );
        nemesis.setCount( rs.getLong( "count" ) );
        return nemesis;
    }

}
