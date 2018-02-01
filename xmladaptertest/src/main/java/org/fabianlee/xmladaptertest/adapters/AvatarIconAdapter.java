package org.fabianlee.xmladaptertest.adapters;

import javax.xml.bind.annotation.adapters.XmlAdapter;

import org.fabianlee.xmladaptertest.domain.AvatarIcon;

public class AvatarIconAdapter extends XmlAdapter<String,AvatarIcon> {
	
	// take input xml and convert to internal model
    @Override
    public AvatarIcon unmarshal( String value )
    {
    	if(null==value) return null;
    	return new AvatarIcon(javax.xml.bind.DatatypeConverter.parseBase64Binary(value));
    }
	
    // output value to xml
    @Override
    public String marshal( AvatarIcon value )
    {
    	if(null==value.getImage()) return null;
    	return javax.xml.bind.DatatypeConverter.printBase64Binary(value.getImage());
    }

}
