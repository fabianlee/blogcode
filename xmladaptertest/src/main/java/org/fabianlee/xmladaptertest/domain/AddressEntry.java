package org.fabianlee.xmladaptertest.domain;

import javax.xml.bind.annotation.*;
import javax.xml.bind.annotation.adapters.XmlJavaTypeAdapter;

import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;

@XmlAccessorType(XmlAccessType.FIELD)
@XmlRootElement(name="entry")
public class AddressEntry {
	
	@XmlAttribute
	protected String name;
	
	@XmlAttribute(required=false)
	@XmlJavaTypeAdapter(org.fabianlee.xmladaptertest.adapters.GenderEnumAdapter.class)
	protected Gender gender;
	
	@XmlElement(name="avatarIcon",required=false)
	protected AvatarIcon avatar;
	
	
	public AddressEntry() {
		// attribute not required in XML, but still want default value if absent
		gender = new Gender();
	}


	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public Gender getGender() {
		return gender;
	}

	public void setGender(Gender gender) {
		this.gender = gender;
	}

	public AvatarIcon getAvatar() {
		return avatar;
	}

	public void setAvatar(AvatarIcon avatar) {
		this.avatar = avatar;
	}
	
	
	@Override
	public String toString() {
		return ToStringBuilder.reflectionToString(this,ToStringStyle.NO_CLASS_NAME_STYLE);
	}


}
