package here.ameen.hb.dao;

import java.sql.ResultSet;
import java.sql.SQLException;

import org.springframework.jdbc.core.RowMapper;

import here.ameen.hb.model.KD;

public class KDRowMapper
    implements
    RowMapper<KD>
{

    @Override
    public KD mapRow( ResultSet rs, int rowNum )
        throws SQLException
    {
        KD kd = new KD();
        kd.setName( rs.getString( "name" ) );
        kd.setKills( rs.getInt( "kills" ) );
        kd.setDeaths( rs.getInt( "deaths" ) );
        kd.setKd( rs.getDouble( "kd" ) );
        return kd;
    }

}
