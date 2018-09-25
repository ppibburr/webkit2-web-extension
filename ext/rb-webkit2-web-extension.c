#include <ruby.h>

#include <webkit2/webkit-web-extension.h>

static void load_rb(const gchar* data)
{
	ruby_init();
    ruby_init_loadpath();

	char* options[] = {"-V", "-erequire 'webkit2-web-extension'", (char*) data };
	void* node = ruby_options(3, options);

	int state;
	if (ruby_executable_node(node, &state))
	{
		state = ruby_exec_node(node);
	}

	if (state)
	{
		/* handle exception, perhaps */
		printf("fail\n");
	}

	//ruby_cleanup(state);
}


G_MODULE_EXPORT void
webkit_web_extension_initialize_with_user_data (WebKitWebExtension *extension, GVariant* data)
{
    load_rb(g_variant_get_string(data, NULL));
}
