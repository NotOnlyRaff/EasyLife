package com.easylife;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication(scanBasePackages = "com.easylife")
public class EasyLifeApplication {

	public static void main(String[] args) {
		SpringApplication.run(EasyLifeApplication.class, args);
	}

}
