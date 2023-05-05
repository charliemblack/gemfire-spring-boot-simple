/*
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

package gemfire.demo;

import org.apache.geode.cache.GemFireCache;
import org.apache.geode.cache.Region;
import org.apache.geode.cache.client.ClientCache;
import org.apache.geode.cache.client.ClientRegionShortcut;
import org.springframework.boot.SpringApplication;
import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.data.gemfire.config.annotation.ClientCacheApplication;
import org.springframework.data.gemfire.config.annotation.EnableClusterConfiguration;
import org.springframework.data.gemfire.config.annotation.EnableLogging;
import org.springframework.stereotype.Component;

import javax.annotation.Resource;
import java.util.Date;
import java.util.Map;

@EnableClusterConfiguration(useHttp = true, requireHttps = false)
@ClientCacheApplication
@EnableLogging
public class DemoApplication {

    @Bean
    Region<String, String> demo(GemFireCache gemFireCache) {
        ClientCache clientCache = (ClientCache) gemFireCache;
        return clientCache.<String, String>createClientRegionFactory(ClientRegionShortcut.PROXY).create("demo");
    }

    @Component
    class BasicApplication {
        @Resource
        private Map<String, String> demo;

        private void doSomething() {
            demo.put("hello", "world " + new Date());
            System.out.println("demo.get(\"hello\") = " + demo.get("hello"));
        }
    }

    public static void main(String[] args) {
        System.out.println("DemoApplication.main");
        ApplicationContext context = SpringApplication.run(DemoApplication.class, args);

        BasicApplication demoApplication = context.getBean(BasicApplication.class);
        demoApplication.doSomething();
    }
}

