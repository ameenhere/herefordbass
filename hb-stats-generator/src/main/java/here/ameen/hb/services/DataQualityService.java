package here.ameen.hb.services;

import java.util.List;

public interface DataQualityService
{
    List<String> fixIncorrectNames(List<String[]> names);
}
