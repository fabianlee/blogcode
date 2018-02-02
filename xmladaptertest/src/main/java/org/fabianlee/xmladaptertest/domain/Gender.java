package org.fabianlee.xmladaptertest.domain;

import java.io.Serializable;

public class Gender implements Serializable {
	
	// default value
	private GenderEnum gender = GenderEnum.UNSPECIFIED;

	public Gender() {
	}
	public Gender(GenderEnum gender) {
		super();
		this.gender = gender;
	}


	public GenderEnum getGender() {
		return gender;
	}
	public void setGender(GenderEnum gender) {
		this.gender = gender;
	}

	
	@Override
	public String toString() {
		if(null==gender) return GenderEnum.UNSPECIFIED.name();
		return gender.name();
	}

}
