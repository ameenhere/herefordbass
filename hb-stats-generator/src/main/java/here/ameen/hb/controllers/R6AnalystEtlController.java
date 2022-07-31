package here.ameen.hb.controllers;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping( value = "/r6a", method = RequestMethod.GET )
public class R6AnalystEtlController
{


    @RequestMapping( value = "/csv", method = RequestMethod.POST )
    public String uploadR6AnalystCsv( @RequestParam("file") MultipartFile file  )
    {
        return "Success";
    }

 
}
