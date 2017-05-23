package application;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.web.support.SpringBootServletInitializer;
import org.springframework.context.annotation.ComponentScan;

 

@SpringBootApplication
//@ComponentScan
//@EnableAutoConfiguration
@ComponentScan(basePackages="/resource")
public class JavaDayTokyoApplication extends SpringBootServletInitializer{
	
	@Override
	protected SpringApplicationBuilder configure(SpringApplicationBuilder application) {
		return application.sources(JavaDayTokyoApplication.class);
	}
	
	public static void main(String[] args) {
		SpringApplication.run(JavaDayTokyoApplication.class, args);
		System.out.println("Beans provided by Spring Boot:");

        /*String[] beanNames = ctx.getBeanDefinitionNames();
        Arrays.sort(beanNames);
        for (String beanName : beanNames) {
            System.out.println(beanName);
        }*/
	}
}
