---
title: "Spring Data JPA 使用入门"
date: 2020-07-14T22:12:23+08:00
draft: false
categories: 
  - program
  - spring data jpa
tags: 
  - spring data jpa
---

![](https://b3logfile.com/bing/20190816.jpg?imageView2/1/w/960/h/540/interlace/1/q/100)

## 前言

我一直认为 **Spring Data JPA** 是一个好东西，有着自己独特的黑魔法。但是由于目前接触甚少，不知道该如何开启。所以想通过从无到有的过程，逐渐的去认识它，搞清楚它与Mybatis的关系，如果站在架构的角度看会怎么怎么样的情况。在这个过程中，会使用文字的方式将过程记录下来，也算是一点经历。

<!-- more -->

## Spring Data JPA 介绍

[From spring.io](https://spring.io/projects/spring-data-jpa)：Spring Data JPA是Spring Data系列的一个组成部分，可以轻松快捷的实现数据访问层的增强支持，这使得基于Spring且使用了数据库访问技术的应用程序更加容易构建。Spring Data JPA 内置了简单数据库读写操作，包括分页查询，并提供接口以待增强。

Spring Data JPA 是基于Hibernate（在3.2版本中便对JPA提供了完全的支持）、JPA规范的基础上封装的一套ORM框架，可以说就是JPA规范的一个实践落地的产品。Spring Data JPA的内置实现中提供了包括增删改查、分页、自定义SQL的常用功能，且提供接口以待拓展增强。基于Spring Data JPA可以简洁的代码，快速的实现对数据库的访问。

## 使用示例

> 环境说明:
>
> - windows 10 专业版
> - IntelliJ IDEA 2019.3.1
> - JDK 1.8
> - maven 3.6.1
> - Spring Boot 2.2.5.RELEASE

### 引入依赖

```java
 <dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-jpa</artifactId>
</dependency>

<!-- 我这里使用mysql作为数据存储 -->
<dependency>
    <groupId>mysql</groupId>
    <artifactId>mysql-connector-java</artifactId>
    <scope>runtime</scope>
</dependency>

<dependency>
    <groupId>org.projectlombok</groupId>
    <artifactId>lombok</artifactId>
    <optional>true</optional>
</dependency>
```

### 定义一个简单实体

```java
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;

/** 
  * @author zhoujian 
  */ 
  
@Entity
public class Customer {

   @Id
   @GeneratedValue(strategy= GenerationType.AUTO)
   private Long id;
   private String firstName;
   private String lastName;
   
   protected Customer() {}
   
   public Customer(String firstName, String lastName) {
       this.firstName = firstName;
       this.lastName = lastName;
   }
   
   public Long getId() { return id; }
   
   public void setId(Long id) { his.id = id; }
   
   public String getFirstName() { return firstName; }
   
   public String getLastName() { return lastName; }
   
   @Override
   public String toString() {
       return String.format("Customer[id=%d, firstName='%s', lastName='%s']", id, firstName, lastName);
   }
}
```

### 创建查询接口

```java

import org.springframework.data.repository.CrudRepository;

import java.util.List;
/** 
  * {@link Customer}实体的仓库接口 
  * @author zhoujian 
  */
public interface CustomerRepository extends CrudRepository<Customer, Long> {

   /**     
     * 根据{@link Customer#lastName}查询数据     
     * @param lastName {@link Customer}的属性     
     * @return customer list     
     */
  List<Customer> findByLastName(String lastName);}
```

### 简单测试

这里只是方便测试，所以直接使用了 CommandLineRunner 进行业务测试，在这里也直接与 Repository 层耦合，也不是通过单元测试，并不推荐这样的做法。

```java
import org.slf4j.Logger;import org.slf4j.LoggerFactory;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;

/** 
  * @author zhoujian 
  */
@SpringBootApplication
public class ForTestOrmApplication {
  
   public static void main(String[] args) {
      SpringApplication.run(ForTestOrmApplication.class, args);
   }
  
   private static final Logger LOG = LoggerFactory.getLogger(ForTestOrmApplication.class);

   @Bean
   public CommandLineRunner jpaTestRunner(CustomerRepository customerRepository){
   
       return (args) -> {
   
           // 插入五条 customer 数据
           customerRepository.save(new Customer("Jack", "Liu"));
           customerRepository.save(new Customer("Mary", "Liu"));
           customerRepository.save(new Customer("Bob", "Huang"));
           customerRepository.save(new Customer("Jim", "Chen"));
           customerRepository.save(new Customer("David", "Gao"));

           // 获取所有的 customer 数据
           LOG.info("pull all customers with findAll():");
           LOG.info("---------------------------------");
           customerRepository.findAll().forEach(
               customer -> LOG.info("Customer is : {}", customer.toString())
           );
   
           // 获取所有的 customer 数据
           LOG.info("pull all customers with findByLastName():");
           LOG.info("---------------------------------");
   
           customerRepository.findByLastName("Liu").forEach(
               customer -> LOG.info("Customer is : {}", customer.toString())
           );
       };
   }
}
```

测试期望如下：

```java
2020-04-20 08:50:01.195  INFO 12016 --- [           main] c.j.for_test_orm.ForTestOrmApplication   : pull all customers with findAll():
2020-04-20 08:50:01.195  INFO 12016 --- [           main] c.j.for_test_orm.ForTestOrmApplication   : ---------------------------------
Hibernate: select customer0_.id as id1_0_, customer0_.first_name as first_na2_0_, customer0_.last_name as last_nam3_0_ from customer customer0_
2020-04-20 08:50:01.293  INFO 12016 --- [           main] c.j.for_test_orm.ForTestOrmApplication   : Customer is : Customer[id=1, firstName='Jack', lastName='Liu']
2020-04-20 08:50:01.293  INFO 12016 --- [           main] c.j.for_test_orm.ForTestOrmApplication   : Customer is : Customer[id=2, firstName='Mary', lastName='Liu']
2020-04-20 08:50:01.293  INFO 12016 --- [           main] c.j.for_test_orm.ForTestOrmApplication   : Customer is : Customer[id=3, firstName='Bob', lastName='Huang']
2020-04-20 08:50:01.293  INFO 12016 --- [           main] c.j.for_test_orm.ForTestOrmApplication   : Customer is : Customer[id=4, firstName='Jim', lastName='Chen']
2020-04-20 08:50:01.293  INFO 12016 --- [           main] c.j.for_test_orm.ForTestOrmApplication   : Customer is : Customer[id=5, firstName='David', lastName='Gao']
2020-04-20 08:50:01.293  INFO 12016 --- [           main] c.j.for_test_orm.ForTestOrmApplication   : pull all customers with findByLastName():
2020-04-20 08:50:01.293  INFO 12016 --- [           main] c.j.for_test_orm.ForTestOrmApplication   : ---------------------------------
Hibernate: select customer0_.id as id1_0_, customer0_.first_name as first_na2_0_, customer0_.last_name as last_nam3_0_ from customer customer0_ where customer0_.last_name=?
2020-04-20 08:50:01.311  INFO 12016 --- [           main] c.j.for_test_orm.ForTestOrmApplication   : Customer is : Customer[id=1, firstName='Jack', lastName='Liu']
2020-04-20 08:50:01.312  INFO 12016 --- [           main] c.j.for_test_orm.ForTestOrmApplication   : Customer is : Customer[id=2, firstName='Mary', lastName='Liu']
```

---
## 参考

- [guides/accessing-data-jpa](https://spring.io/guides/gs/accessing-data-jpa/)
