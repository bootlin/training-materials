#include <directfb.h>
#include <unistd.h>
#include <string.h>

IDirectFB               *dfb;
IDirectFBSurface        *primary;
IDirectFBImageProvider  *provider;

DFBSurfaceDescription    dsc;

int main(int argc, char *argv[])
{
  DirectFBInit(&argc, &argv);
  DirectFBCreate(&dfb);

  dfb->SetCooperativeLevel(dfb, DFSCL_FULLSCREEN);

  /* Primary */
  memset(&dsc, 0, sizeof(DFBSurfaceDescription));
  dsc.flags = DSDESC_CAPS;
  dsc.caps = DSCAPS_PRIMARY;
  dfb->CreateSurface(dfb, &dsc, &primary);

  /* Background */
  dfb->CreateImageProvider(dfb, "background.png", &provider);
  provider->RenderTo(provider, primary, NULL);
  provider->Release(provider);

  sleep(5);

  primary->Release(primary);
  dfb->Release(dfb);
  return 0;
}

