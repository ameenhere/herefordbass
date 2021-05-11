package here.ameen.hb.services;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import here.ameen.hb.dao.DataQualityDao;

@Service
public class DefaultDataQualityService
    implements
    DataQualityService
{
    @Autowired
    private DataQualityDao dataQualityDao;

    @Override
    public List<String> fixIncorrectNames( List<String[]> names )
    {

        return dataQualityDao.fixIncorrectNames( names );
    }

}
