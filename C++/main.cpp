#include <QApplication>
#include <QQmlEngine>
#include <QQmlComponent>
#include <QQmlContext>
#include <QDebug>
#include "settings.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    QQmlEngine engine;

    settings setts;
    engine.rootContext()->setContextProperty("settings", &setts);

    QQmlComponent component(&engine, QUrl(QStringLiteral("qrc:/qml/main.qml")));
    component.create();

    QObject::connect(engine.rootContext()->engine(), SIGNAL(quit()), qApp, SLOT(quit()));
    return app.exec();

    /*try {
        app.exec();
    } catch (const std::bad_alloc &) {
        // clean up here, e.g. save the session
        // and close all config files.

        return 0; // exit the application
    }*/
}
