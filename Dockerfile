FROM caddy:builder AS builder

# 将插件列表复制到构建环境中
COPY plugins.list /tmp/plugins.list

# 动态解析 plugins.list 并进行构建
RUN set -e; \
    WITH_ARGS=""; \
    while IFS= read -r line || [ -n "$line" ]; do \
        # 忽略空行和以#开头的注释行
        if echo "$line" | grep -Eq '^[[:space:]]*(#|$)'; then \
            continue; \
        fi; \
        # 提取第一个冒号后面的内容作为 URL
        url=$(echo "$line" | sed 's/^[^:]*://'); \
        # 移除可能的前后空白字符
        url=$(echo "$url" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'); \
        WITH_ARGS="$WITH_ARGS --with $url"; \
    done < /tmp/plugins.list; \
    echo "Building Caddy with args: $WITH_ARGS"; \
    eval "xcaddy build $WITH_ARGS --output /usr/bin/caddy"

# 第二阶段：构建最终运行的精简镜像
FROM caddy:alpine

# 从 builder 阶段复制编译好的 caddy 二进制文件，覆盖默认的
COPY --from=builder /usr/bin/caddy /usr/bin/caddy

# 可选：如果需要验证插件是否正确编译进来，可以在构建镜像时执行 list-modules 检查
RUN /usr/bin/caddy list-modules
