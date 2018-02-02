package org.fabianlee.xmladaptertest.domain;

import java.io.Serializable;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlRootElement;

@XmlAccessorType(XmlAccessType.FIELD)
@XmlRootElement(name="avatarIcon")
public class AvatarIcon implements Serializable {
	
	private byte[] image;
	
	public AvatarIcon() {
	}
	public AvatarIcon(byte[] image) {
		super();
		this.image = image;
	}
	
	public byte[] getImage() {
		return image;
	}
	public void setImage(byte[] image) {
		this.image = image;
	}
	

	@Override
	public String toString() {
		return (image==null ? 0:image.length) + " bytes";
	}
	

}
