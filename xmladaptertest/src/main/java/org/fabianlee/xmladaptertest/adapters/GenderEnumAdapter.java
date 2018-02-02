package org.fabianlee.xmladaptertest.adapters;

import javax.xml.bind.annotation.adapters.XmlAdapter;

import org.fabianlee.xmladaptertest.domain.Gender;
import org.fabianlee.xmladaptertest.domain.GenderEnum;

public class GenderEnumAdapter extends XmlAdapter<String,Gender> {
	
	// take input xml and convert to internal model
    @Override
    public Gender unmarshal( String value )
    {
    	if(null==value) {
    		return new Gender(GenderEnum.UNSPECIFIED);
    	}else if(value.equalsIgnoreCase("m") || value.equalsIgnoreCase("male")) {
    		return new Gender(GenderEnum.MALE);
    	}else if(value.equalsIgnoreCase("f") || value.equalsIgnoreCase("female")) {
    		return new Gender(GenderEnum.FEMALE);
    	}else {
    		return new Gender(GenderEnum.CHOOSE_NOT_TO_SPECIFY);
    	}
    }
	
    // output value to xml
    @Override
    public String marshal( Gender value )
    {
    	if(null==value) {
    		return GenderEnum.UNSPECIFIED.name();
    	}else {
    		return value.toString();
    	}
    }

}
