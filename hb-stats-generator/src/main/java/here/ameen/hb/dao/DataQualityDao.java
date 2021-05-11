package here.ameen.hb.dao;

import java.util.List;

public interface DataQualityDao
{
    List<String> fixIncorrectNames(List<String[]> names);
}
