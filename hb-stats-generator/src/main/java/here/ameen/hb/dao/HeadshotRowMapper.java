package here.ameen.hb.dao;

import java.sql.ResultSet;
import java.sql.SQLException;

import org.springframework.jdbc.core.RowMapper;

import here.ameen.hb.model.Headshot;

public class HeadshotRowMapper
    implements
    RowMapper<Headshot>
{

    @Override
    public Headshot mapRow( ResultSet rs, int rowNum )
        throws SQLException
    {
        Headshot headshot = new Headshot();
        headshot.setName( rs.getString( "name" ) );
        headshot.setHeadshots( rs.getLong( "headshots" ) );
        return headshot;
    }

}
