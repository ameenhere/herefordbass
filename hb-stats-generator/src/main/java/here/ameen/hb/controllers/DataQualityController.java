package here.ameen.hb.controllers;

import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import here.ameen.hb.services.DataQualityService;

@RestController
@RequestMapping( value = "/quality", method = RequestMethod.GET )
public class DataQualityController
{
    
    @Autowired
    private DataQualityService dataQualityService;
    
    @RequestMapping( value = "/names", method = RequestMethod.GET )
    public List<String> fixPlayerNames( @RequestParam( required = false, value = "season" ) Integer season )
    {
        List<String[]> names = new ArrayList<>();
        names.add(new String[]{"CalLycus","calLycus"});
        names.add(new String[]{"Marras","marras"});
     
//        names.add(new String[]{"Tommy","TommyKL"});
        
        return dataQualityService.fixIncorrectNames( names );
    }
}
